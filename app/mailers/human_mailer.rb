# Just a mailer
class HumanMailer < ApplicationMailer
  default from: 'noreply@funnyway.ru'

  def account_activation(human, token)
    @human = human
    @activation_url = activation_url(token: token,
                                     email: @human.email,
                                     locale: I18n.locale)
    mail(to: @human.email, subject: t(:mailer_activation_subject))
  end

  def password_reset(human, token)
    @human = human
    @reset_password_url = reset_password_url(token: token,
                                             email: @human.email,
                                             locale: I18n.locale)
    mail(to: @human.email, subject: t(:mailer_password_subject))
  end

  def send_password(human, token)
    @human = human
    @password = token
    mail(to: @human.email, subject: t(:mailer_new_password_subject))
  end
end
