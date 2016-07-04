require "test_helper"
require_relative 'support/ui_test_helper'

class CreateNewSchemaVersionTest < Capybara::Rails::TestCase
  include UITestHelper
  include Warden::Test::Helpers
  after { Warden.test_reset! }

  setup do
    visit root_path
    login_as users(:pablito), scope: :user
    visit root_path
    click_schema_category "Anotaciones"
    click_link "AnotacionesSchema1"
    click_link "Nueva Versión"
    assert_content page, "Seleccionar Archivo"
    page.execute_script('$("input[type=file]").show()')
  end

  test "attempt to create a schema without an attached file" do
    click_button "Subir Nueva Versión"
    assert_content page, "No se pudo crear nueva versión"
  end

  test "attempt to create a schema with an invalid file" do
    attach_file 'schema_version_spec_file', Rails.root.join('README.md')
    click_button "Subir Nueva Versión"
    assert_content page, "No se pudo crear nueva versión"
  end

  test "create a valid schema" do
    attach_file 'schema_version_spec_file', Rails.root.join(
      'test', 'files', 'test-schemas', 'schemaObject.json')
    click_button "Subir Nueva Versión"
    assert_content page, "Nueva versión creada correctamente"
  end
end