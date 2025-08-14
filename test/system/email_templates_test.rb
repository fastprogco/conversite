require "application_system_test_case"

class EmailTemplatesTest < ApplicationSystemTestCase
  setup do
    @email_template = email_templates(:one)
  end

  test "visiting the index" do
    visit email_templates_url
    assert_selector "h1", text: "Email templates"
  end

  test "should create email template" do
    visit email_templates_url
    click_on "New email template"

    fill_in "Html", with: @email_template.html
    fill_in "Title", with: @email_template.title
    click_on "Create Email template"

    assert_text "Email template was successfully created"
    click_on "Back"
  end

  test "should update Email template" do
    visit email_template_url(@email_template)
    click_on "Edit this email template", match: :first

    fill_in "Html", with: @email_template.html
    fill_in "Title", with: @email_template.title
    click_on "Update Email template"

    assert_text "Email template was successfully updated"
    click_on "Back"
  end

  test "should destroy Email template" do
    visit email_template_url(@email_template)
    click_on "Destroy this email template", match: :first

    assert_text "Email template was successfully destroyed"
  end
end
