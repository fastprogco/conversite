require "application_system_test_case"

class EmailSettingsTest < ApplicationSystemTestCase
  setup do
    @email_setting = email_settings(:one)
  end

  test "visiting the index" do
    visit email_settings_url
    assert_selector "h1", text: "Email settings"
  end

  test "should create email setting" do
    visit email_settings_url
    click_on "New email setting"

    fill_in "Email address", with: @email_setting.email_address
    fill_in "Name", with: @email_setting.name
    fill_in "Password", with: @email_setting.password
    fill_in "Port", with: @email_setting.port
    fill_in "Smtp host", with: @email_setting.smtp_host
    fill_in "User name", with: @email_setting.user_name
    click_on "Create Email setting"

    assert_text "Email setting was successfully created"
    click_on "Back"
  end

  test "should update Email setting" do
    visit email_setting_url(@email_setting)
    click_on "Edit this email setting", match: :first

    fill_in "Email address", with: @email_setting.email_address
    fill_in "Name", with: @email_setting.name
    fill_in "Password", with: @email_setting.password
    fill_in "Port", with: @email_setting.port
    fill_in "Smtp host", with: @email_setting.smtp_host
    fill_in "User name", with: @email_setting.user_name
    click_on "Update Email setting"

    assert_text "Email setting was successfully updated"
    click_on "Back"
  end

  test "should destroy Email setting" do
    visit email_setting_url(@email_setting)
    click_on "Destroy this email setting", match: :first

    assert_text "Email setting was successfully destroyed"
  end
end
