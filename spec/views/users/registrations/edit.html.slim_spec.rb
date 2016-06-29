require 'rails_helper'

describe 'users/registrations/edit.html.slim' do
  context 'user is not TOTP enabled' do
    before do
      user = build_stubbed(:user, :signed_up)
      allow(view).to receive(:current_user).and_return(user)
      @update_user_profile_form = UpdateUserProfileForm.new(user)
    end

    it 'has a localized title' do
      expect(view).to receive(:title).with(t('upaya.titles.registrations.edit', app_name: APP_NAME))

      render
    end

    it 'sets form autocomplete to off' do
      render

      expect(rendered).to have_xpath("//form[@autocomplete='off']")
    end

    it 'contains link to enable TOTP' do
      render

      expect(rendered).to have_xpath("//input[@value='Enable']")
      expect(rendered).not_to have_xpath("//input[@value='Disable']")
    end

    it 'contains link to delete account' do
      render

      expect(rendered).to have_content t('upaya.headings.delete_account')
      expect(rendered).
        to have_xpath("//input[@value='#{t('upaya.forms.buttons.delete_account')}']")
    end
  end

  context 'when user is TOTP enabled' do
    it 'contains link to disable TOTP' do
      user = build_stubbed(:user, :signed_up, otp_secret_key: '123')
      allow(view).to receive(:current_user).and_return(user)
      @update_user_profile_form = UpdateUserProfileForm.new(user)

      render

      expect(rendered).to have_xpath("//input[@value='Disable']")
      expect(rendered).not_to have_xpath("//input[@value='Enable']")
    end
  end
end
