FactoryGirl.define do
  factory :message_for_all, class: Message do
    message 'test_for_all'
    start_date Chronic.parse('now').strftime('%Y-%m-%d')
    end_date Chronic.parse('now').strftime('%Y-%m-%d')
    show_all true
  end

  factory :message_for_no_certificate, class: Message do
    message 'test_for_no_certificate'
    start_date Chronic.parse('now').strftime('%Y-%m-%d')
    end_date Chronic.parse('now').strftime('%Y-%m-%d')
    show_all false
    show_no_certificate true
  end

  factory :message_for_credit_less, class: Message do
    message 'test_for_credit_less'
    start_date Chronic.parse('now').strftime('%Y-%m-%d')
    end_date Chronic.parse('now').strftime('%Y-%m-%d')
    show_all false
    show_credit_less 1
  end

  factory :message_yesterday, class: Message do
    message 'test_yesterday'
    start_date Chronic.parse('yesterday').strftime('%Y-%m-%d')
    end_date Chronic.parse('yesterday').strftime('%Y-%m-%d')
    show_all true
  end

end
