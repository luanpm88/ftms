require 'test_helper'

class BooksContactsControllerTest < ActionController::TestCase
  setup do
    @books_contact = books_contacts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:books_contacts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create books_contact" do
    assert_difference('BooksContact.count') do
      post :create, books_contact: { book_id: @books_contact.book_id, contact_id: @books_contact.contact_id, course_register_id: @books_contact.course_register_id, discount: @books_contact.discount, discount_program_id: @books_contact.discount_program_id, price: @books_contact.price, volumn_ids: @books_contact.volumn_ids }
    end

    assert_redirected_to books_contact_path(assigns(:books_contact))
  end

  test "should show books_contact" do
    get :show, id: @books_contact
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @books_contact
    assert_response :success
  end

  test "should update books_contact" do
    patch :update, id: @books_contact, books_contact: { book_id: @books_contact.book_id, contact_id: @books_contact.contact_id, course_register_id: @books_contact.course_register_id, discount: @books_contact.discount, discount_program_id: @books_contact.discount_program_id, price: @books_contact.price, volumn_ids: @books_contact.volumn_ids }
    assert_redirected_to books_contact_path(assigns(:books_contact))
  end

  test "should destroy books_contact" do
    assert_difference('BooksContact.count', -1) do
      delete :destroy, id: @books_contact
    end

    assert_redirected_to books_contacts_path
  end
end
