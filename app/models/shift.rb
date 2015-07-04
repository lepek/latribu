class Shift < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :instructor
  belongs_to :discipline
  has_many :inscriptions
  has_many :users, through: :inscriptions
  has_many :rookies

  DAYS = {:monday => 'lunes', :tuesday => 'martes', :wednesday => 'miércoles', :thursday => 'jueves', :friday => 'viernes', :saturday => 'sábado', :sunday => 'domingo'}

  # I can use this later
  STATUS = {:open => 'abierta', :close => 'cerrada', :full => 'completa'}

  DEFAULT_SHIFT_DURATION = 1
  MARTIN_BIANCULLI_ID = 2
  MARCELO_PERRETTA_ID =  41
  IVAN_TREVISAN_ID = 7
  ALLOWED_USERS = [MARTIN_BIANCULLI_ID, MARCELO_PERRETTA_ID, IVAN_TREVISAN_ID]

  before_destroy :remove_inscriptions

  validates_presence_of :day, :start_time, :end_time, :max_attendants, :open_inscription, :close_inscription, :instructor, :discipline, :cancel_inscription
  validates_uniqueness_of :start_time, :scope => [:day]

  def self.days
    DAYS
  end

  ##
  # @return The next class of all the shift collection in the database
  #
  def self.get_next_class
    @shift = Shift.where(
        'day = ? AND end_time > ?',
        Chronic.parse("now").strftime('%A').downcase,
        Chronic.parse("now").strftime('%H:%M')
    ).eager_load(:instructor, :discipline).order("end_time ASC").first
  end

  ##
  # @return The specific date of the next class of this shift
  #
  def next_fixed_shift
    @next_fixed_shift ||= get_next_shift
  end

  ##
  # @return The specific date of the current or next class of this shift
  #
  def current_fixed_shift
    @current_fixed_shift ||= get_next_shift(self.end_time.strftime('%H:%M'))
  end

  ##
  # @return [ActiveRecord::Relation] inscriptions for the next class of this shift
  #
  def next_fixed_shift_users
    self.inscriptions.where(:shift_date => self.next_fixed_shift)
  end

  def next_fixed_shift_rookies
    self.rookies.where(:shift_date => self.next_fixed_shift)
  end

  ##
  # @return Number of inscriptions for the next shift
  #
  def next_fixed_shift_count
    count = $redis.cache(:key => redis_key) { next_fixed_shift_count_db }
    count.to_i
  end

  ##
  # @return Number of inscriptions for the current or next shift
  #
  def current_fixed_shift_count
    self.current_fixed_shift_users.count + self.current_fixed_shift_rookies.count
  end

  def current_fixed_shift_users
    self.inscriptions.where(:shift_date => self.current_fixed_shift)
  end

  def current_fixed_shift_rookies
    self.rookies.where(:shift_date => self.current_fixed_shift)
  end

  def enroll_next_shift(user)
    if available_for_enroll?(user)
      self.inscriptions << Inscription.create({:user_id => user.id, :shift_date => self.next_fixed_shift})
      $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
    else
      self.errors[:base] << "No es posible anotarse a la clase, ya está anotado, está cerrada o completa"
      false
    end
  end

  def needs_confirmation?
    Chronic.parse("now") > Chronic.parse("#{self.cancel_inscription} hours ago", :now => self.next_fixed_shift)
  end

  def cancel_next_shift(user)
    if available_for_cancel?(user)
      self.inscriptions.where({:user_id => user.id, :shift_date => self.next_fixed_shift}).first.destroy
      $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
    else
      self.errors[:base] << "No es posible liberar la clase, ya está cerrada o no está anotado"
      false
    end
  end

  def enroll_next_shift_rooky(rooky)
    if self.available_for_try?
      rooky.shift_date ||= get_next_shift
      rooky.shift_id ||= self.id
      rooky.save!
      $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
    else
      self.errors[:base] << "No es posible anotarse a la clase, ya está anotado, está cerrada o completa"
    end
  end

  def cancel_inscription_rooky
    $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
  end

  ##
  # @param user [User] the user we would like to enroll
  # @return [Boolean] if the shift is available to enroll a user or not
  #
  def available_for_enroll?(user)
    @available_for_enroll ||= self.exceptions?(user)
    @available_for_enroll ||= ( self.status == STATUS[:open] && self.user_inscription(user).nil? && user.credit > 0 && user.disciplines.include?(self.discipline) && self.another_today_inscription?(user).nil? )
  end

  def exceptions?(user)
    ALLOWED_USERS.include?(user.id) && self.status != STATUS[:full] && self.user_inscription(user).nil? && user.credit > 0 && user.disciplines.include?(self.discipline)
  end

  ##
  # @return [Boolean] if the shift is available to enroll an anonymous user for a free class or not
  #
  def available_for_try?
    status != STATUS[:full]
  end

  def available_for_cancel?(user)
    user_inscription(user) && (status != STATUS[:close] && !needs_confirmation? || ALLOWED_USERS.include?(user.id) )
  end

  ##
  # @return nil or the inscription record of the user
  #
  def user_inscription(user)
    user.next_inscriptions.find { |i| i.shift_date == self.next_fixed_shift }
  end

  def another_today_inscription?(user)
    user.next_inscriptions.find { |i| i.shift_date.strftime('%D') == self.next_fixed_shift.strftime('%D') && i.shift.discipline == self.discipline }
  end

  def day_and_time
    "#{DAYS[self.day.to_sym].capitalize} #{self.start_time.strftime('%H:%M')} hs."
  end

  ##
  # When removing a shift we remove the inscriptions to that shift and refund the credits
  #
  def remove_inscriptions
    self.next_fixed_shift_users.destroy_all
  end

  # current_time = 10:00
  # 12:00 - 3 = 9:00 => 9:00 < 10:00 => cerrada
  # start_time - close_inscription < current time => cerrada
  #
  # current_time = 7:00
  # 12:00 - 10 = 2:00 < 7:00 => abierta (and the cerrada is not met)
  # start_time - open_inscription < current_time => abierta
  def status
    return STATUS[:full] if self.next_fixed_shift_count >= self.max_attendants

    hours_diff = (self.next_fixed_shift - Chronic.parse("now")) / 3600
    if hours_diff > self.close_inscription && hours_diff < self.open_inscription
      STATUS[:open]
    else
      STATUS[:close]
    end

  end

  def close?
    status == STATUS[:close]
  end

private

  def get_next_shift(shift_time = self.start_time.strftime('%H:%M'))
    if Chronic.parse("#{self.day.to_s} #{shift_time}", :now => Chronic.parse("now") - 1.day) > Chronic.parse("now")
      @fixed_shift = Chronic.parse("#{self.day.to_s} #{self.start_time.strftime('%H:%M')}", :now => Chronic.parse("now") - 1.day)
    else
      @fixed_shift = Chronic.parse("#{self.day.to_s} #{self.start_time.strftime('%H:%M')}")
    end
    @fixed_shift
  end

  def next_fixed_shift_count_db
    self.next_fixed_shift_users.count + self.next_fixed_shift_rookies.count
  end

  def redis_key
    "#{self.next_fixed_shift.to_s.gsub(/\s/, '_')} #{self.id}"
  end

end
