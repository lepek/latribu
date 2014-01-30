class Shift < ActiveRecord::Base
  belongs_to :instructor
  belongs_to :discipline
  has_many :inscriptions
  has_many :users, through: :inscriptions
  has_many :rookies

  DAYS = {:monday => 'lunes', :tuesday => 'martes', :wednesday => 'miércoles', :thursday => 'jueves', :friday => 'viernes', :saturday => 'sábado', :sunday => 'domingo'}

  # I can use this later
  STATUS = {:open => 'abierta', :close => 'cerrada', :full => 'completa'}

  DEFAULT_SHIFT_DURATION = 1

  before_validation :set_end_time
  before_destroy :remove_inscriptions

  validates_presence_of :day, :start_time, :max_attendants, :open_inscription, :close_inscription, :instructor, :discipline
  validates_uniqueness_of :start_time, :scope => [:day, :discipline_id]

  def self.days
    DAYS
  end

  ##
  # @return The specific date of the next fixed shift
  #
  def next_fixed_shift
    get_next_shift
  end

  def current_fixed_shift
    get_next_shift(self.end_time.strftime('%H:%M'))
  end

  def self.get_next_class
    @shift = Shift.where(
        'day = ? AND end_time > ?',
        Chronic.parse("now").strftime('%A').downcase,
        Chronic.parse("now").strftime('%H:%M')
    ).order("end_time ASC").first
  end

  ##
  # @return [ActiveRecord::Relation] inscriptions for this Shift
  #
  def next_fixed_shift_users
    self.inscriptions.where(:shift_date => next_fixed_shift)
  end

  def next_fixed_shift_rookies
    self.rookies.where(:shift_date => next_fixed_shift)
  end

  def next_fixed_shift_count
    self.next_fixed_shift_users.count + self.next_fixed_shift_rookies.count
  end

  def current_fixed_shift_users
    self.inscriptions.where(:shift_date => current_fixed_shift)
  end

  def current_fixed_shift_rookies
    self.rookies.where(:shift_date => current_fixed_shift)
  end

  def enroll_next_shift(user)
    if available_for_enroll?(user)
      Inscription.create({:shift_id => self.id, :user_id => user.id, :shift_date => get_next_shift})
    else
      self.errors[:base] << "No es posible anotarse a la Clase, ya está anotado, está cerrada o completa"
    end
  end

  def cancel_next_shift(user)
    if available_for_cancel?(user)
      Inscription.where({:shift_id => self.id, :user_id => user.id, :shift_date => get_next_shift}).first.destroy
    else
      self.errors[:base] << "No es posible liberar la Clase, ya está cerrada o no está anotado"
    end
  end

  def enroll_next_shift_rooky(rooky)
    if self.available_for_try?
      rooky.shift_date ||= get_next_shift
      rooky.shift_id ||= self.id
      rooky.save
    else
      self.errors[:base] << "No es posible anotarse a la Clase, ya está anotado, está cerrada o completa"
    end
  end

  ##
  # @param user [User] the user we would like to enroll
  # @return [Boolean] if the shift is available to enroll a user or not
  #
  def available_for_enroll?(user)
    status == STATUS[:open] && !user_inscription(user) && (user.credit > 0 || user.admin?)
  end

  ##
  # @return [Boolean] if the shift is available to enroll an anonymous user for a free class or not
  #
  def available_for_try?
    status == STATUS[:open]
  end

  def available_for_cancel?(user)
    user_inscription(user) && status != STATUS[:close]
  end

  def user_inscription(user)
    self.inscriptions.where(:user_id => user.id, :shift_date => get_next_shift).first
  end

  def set_end_time
    self.end_time ||= self.start_time + DEFAULT_SHIFT_DURATION.hours unless self.start_time.blank?
  end

  def day_and_time
    return "#{DAYS[self.day.to_sym].capitalize} #{self.start_time.strftime('%H:%M')} hs."
  end

  ##
  # When removing a shift we remove the inscriptions to that shift and refund the credits
  #
  def remove_inscriptions
    self.inscriptions.destroy_all
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

    next_shift = get_next_shift

    hours_diff = (next_shift - Chronic.parse("now")) / 3600
    if hours_diff > self.close_inscription && hours_diff < self.open_inscription
      STATUS[:open]
    else
      STATUS[:close]
    end

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

end
