class Shift < ActiveRecord::Base

  acts_as_paranoid

  belongs_to :instructor
  belongs_to :discipline
  has_many :inscriptions
  has_many :users, through: :inscriptions
  has_many :rookies

  # I can use this later
  STATUS = {:open => 'abierta', :close => 'cerrada', :full => 'completa'}

  DEFAULT_SHIFT_DURATION = 1
  MARTIN_BIANCULLI_ID = 2
  MARCELO_PERRETTA_ID =  41
  IVAN_TREVISAN_ID = 7
  #ALLOWED_USERS = [MARTIN_BIANCULLI_ID, MARCELO_PERRETTA_ID, IVAN_TREVISAN_ID]
  ALLOWED_USERS = []

  DISABLE_TEXT_COLOR = '#CCCCCC'
  DISABLE_BG_COLOR = '#EBEBE4'

  before_destroy :remove_inscriptions

  validates_presence_of :week_day, :start_time, :end_time, :max_attendants, :open_inscription, :close_inscription, :instructor, :discipline, :cancel_inscription
  validates_uniqueness_of :start_time, :scope => [:week_day]

  def self.with_discipline_and_instructor
    preload(:discipline, :instructor)
  end

  def self.with_shift_dates(start_date = Chronic.parse("now").strftime('%Y-%m-%d'))
    select(
        "IF (
        '#{start_date}' > STR_TO_DATE(CONCAT(DATE_FORMAT(DATE_ADD('#{start_date}', interval (week_day - DAYOFWEEK('#{start_date}')) day), '%Y-%m-%d'),' ', start_time), '%Y-%m-%d %H:%i'),
        CONCAT(DATE_FORMAT(DATE_ADD('#{start_date}', interval (7 + week_day - DAYOFWEEK('#{start_date}')) day), '%Y-%m-%d'),' ', start_time),
        CONCAT(DATE_FORMAT(DATE_ADD('#{start_date}', interval (week_day - DAYOFWEEK('#{start_date}')) day), '%Y-%m-%d'),' ', start_time)
      ) as next_shift, shifts.*"
    )
  end

  ##
  # @return The next class of all the shift collection in the database
  #
  def self.get_next_class
    Shift.where(
        'week_day >= ? AND end_time > ?',
        Chronic.parse("now").strftime('%w').to_i + 1,
        Chronic.parse("now").strftime('%H:%M')
    ).order("week_day ASC, end_time ASC").limit(1).first
  end

  def as_json(options = {})
    user = options[:user]
    open = available_for_enroll?(user) || available_for_cancel?(user)
    booked = !user_inscription(user).nil?
    end_date = next_fixed_shift + (end_time - start_time).second

    closed_unattended = !open && booked && Chronic.parse('now') < end_date
    description = "Coach: #{instructor.first_name}<br />Anotados: #{next_fixed_shift_count.to_s}"
    description += '<br /> No puede liberarse' if closed_unattended

    {
      id: id,
      title: discipline.name,
      start: next_fixed_shift.strftime('%F %R'),
      end: end_date.strftime('%F %R'),
      color: open || closed_unattended ? discipline.color : DISABLE_BG_COLOR,
      textColor: open || closed_unattended ? discipline.font_color : DISABLE_TEXT_COLOR,
      description: description,
      className: 'calendar-text',
      status: status, # just to show the status
      open: open,
      deadline: cancel_inscription,
      booked: booked,
      needs_confirmation: needs_confirmation?
    }
  end

  ##
  # @return The specific date of the next class of this shift
  #
  def next_fixed_shift
    @next_shift_date ||= Chronic.parse(try(:next_shift)) || Chronic.parse(Shift.with_shift_dates.where(id: id).first.next_shift)
  end

  ##
  # @return [ActiveRecord::Relation] inscriptions for the next class of this shift
  #
  def next_fixed_shift_users
    inscriptions.where(:shift_date => next_fixed_shift)
  end

  def next_fixed_shift_rookies
    rookies.where(:shift_date => next_fixed_shift)
  end

  ##
  # @return Number of inscriptions for the next shift
  #
  def next_fixed_shift_count
    count = $redis.cache(:key => redis_key) { next_fixed_shift_count_db }
    count.to_i
  end

  def enroll_next_shift(user)
    if available_for_enroll?(user.reload)
      self.inscriptions << Inscription.create({:user_id => user.id, :shift_date => next_fixed_shift})
      $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
    else
      self.errors[:base] << "No es posible anotarse a la clase, ya está anotado, está cerrada o completa"
      false
    end
  end

  def needs_confirmation?
    Chronic.parse("now") > Chronic.parse("#{cancel_inscription} hours ago", :now => next_fixed_shift)
  end

  def cancel_next_shift(user)
    if available_for_cancel?(user.reload)
      self.inscriptions.where({:user_id => user.id, :shift_date => next_fixed_shift}).first.destroy
      $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
    else
      self.errors[:base] << "No es posible liberar la clase, ya está cerrada o no está anotado"
      false
    end
  end

  def enroll_next_shift_rooky(rooky)
    if self.available_for_try?
      rooky.shift_date ||= next_fixed_shift
      rooky.shift_id ||= id
      if rooky.save
        $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
        return true
      end
    else
      self.errors[:base] << "No es posible anotarse a la clase, ya está anotado, está cerrada o completa"
    end
    return false
  end

  def cancel_inscription_rooky
    $redis.cache(:key => redis_key, :recalculate => true) { next_fixed_shift_count_db }
  end

  ##
  # @param user [User] the user we would like to enroll
  # @return [Boolean] if the shift is available to enroll a user or not
  #
  def available_for_enroll?(user)
    available_for_enroll = exceptions?(user)
    available_for_enroll ||= ( status == STATUS[:open] && user_inscription(user).nil? && user.credit > 0 && user.disciplines.include?(discipline) && !another_today_inscription?(user) )
  end

  def exceptions?(user)
    ALLOWED_USERS.include?(user.id) && status != STATUS[:full] && user_inscription(user).nil? && user.credit > 0 && user.disciplines.include?(discipline)
  end

  ##
  # @return [Boolean] if the shift is available to enroll an anonymous user for a free class or not
  #
  def available_for_try?
    status != STATUS[:full]
  end

  def available_for_cancel?(user)
    user_inscription(user).present? && (status != STATUS[:close] && !needs_confirmation? || ALLOWED_USERS.include?(user.id) )
  end

  ##
  # @return nil or the inscription record of the user
  #
  def user_inscription(user)
    user.inscriptions.find { |i| i.shift_date == next_fixed_shift }
  end

  def another_today_inscription?(user)
    !user.inscriptions.find { |i| i.shift_date.strftime('%D') == next_fixed_shift.strftime('%D') && i.shift.discipline == discipline }.nil?
  end

  def day_and_time
    "#{I18n.t('date.day_names')[week_day.to_i - 1].capitalize} #{start_time.strftime('%H:%M')} hs."
  end

  ##
  # When removing a shift we remove the inscriptions to that shift and refund the credits
  #
  def remove_inscriptions
    next_fixed_shift_users.destroy_all
  end

  # current_time = 10:00
  # 12:00 - 3 = 9:00 => 9:00 < 10:00 => cerrada
  # start_time - close_inscription < current time => cerrada
  #
  # current_time = 7:00
  # 12:00 - 10 = 2:00 < 7:00 => abierta (and the cerrada is not met)
  # start_time - open_inscription < current_time => abierta
  def status
    return STATUS[:full] if next_fixed_shift_count >= max_attendants

    hours_diff = (next_fixed_shift - Chronic.parse("now")) / 3600
    if hours_diff > close_inscription && hours_diff < open_inscription
      STATUS[:open]
    else
      STATUS[:close]
    end

  end

  def close?
    status == STATUS[:close]
  end

private

  def next_fixed_shift_count_db
    next_fixed_shift_users.count + next_fixed_shift_rookies.count
  end

  def redis_key
    "#{next_fixed_shift.to_s.gsub(/\s/, '_')} #{id}"
  end

end
