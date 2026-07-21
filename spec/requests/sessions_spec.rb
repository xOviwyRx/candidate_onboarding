require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:user) { create(:user, email: "anna@example.com", password: "secret123") }

  describe "GET /session/new" do
    it "renders the sign in form" do
      get new_session_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    it "signs the user in" do
      post session_path, params: { email: user.email, password: "secret123" }

      expect(session[:user_id]).to eq(user.id)
    end

    it "accepts the email in any case, because it is normalized on the record" do
      post session_path, params: { email: "ANNA@Example.com", password: "secret123" }

      expect(session[:user_id]).to eq(user.id)
    end

    it "rejects a wrong password" do
      post session_path, params: { email: user.email, password: "wrong" }

      expect(session[:user_id]).to be_nil
    end

    it "rejects an unknown email" do
      post session_path, params: { email: "nobody@example.com", password: "secret123" }

      expect(session[:user_id]).to be_nil
    end
  end

  describe "DELETE /session" do
    it "signs the user out" do
      post session_path, params: { email: user.email, password: "secret123" }

      delete session_path

      expect(session[:user_id]).to be_nil
    end
  end
end
