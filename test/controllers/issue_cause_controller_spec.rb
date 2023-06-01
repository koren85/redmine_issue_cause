
require "easy_extensions/spec_helper"


RSpec.describe IssueCausesController, logged: true do

  describe "#index" do
    before :each do
      role = Role.non_member
      role.add_permission! :view_issue_causes
    end

    it "html" do
      get :index
      expect(response).to have_http_status :success
    end

    it "json" do
      get :index, params: { format: "json" }
      expect(response).to have_http_status :ok
    end
  end

  describe "#show" do
    before :each do
      role = Role.non_member
      role.add_permission! :view_issue_causes
    end
    subject { FactoryBot.create(:issue_cause) }

    it "with id" do
      get :show, params: { id: subject.id }
      expect(response).to have_http_status :success
    end

    it "not found" do
      get :show, params: { id: "invalid" }
      expect(response).to have_http_status :not_found
    end
  end

  context "manage issue_causes" do
    before :each do
      role = Role.non_member
      role.add_permission! :manage_issue_causes
    end
    describe "#create" do
      it "valid" do
        expect {
          post :create, params: { issue_cause: FactoryBot.attributes_for(:issue_cause), format: "json" }
        }.to change(IssueCause, :count).by 1
        expect(response).to have_http_status :success
      end

      it "invalid" do
        expect {
          post :create, params: { issue_cause: { name: "" }, format: "xml" }
        }.to change(IssueCause, :count).by 0
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    describe "#update" do
      subject { FactoryBot.create(:issue_cause, name: 'value1') }
      it "valid" do
        expect {
          put :update, params: { id: subject, issue_cause: FactoryBot.attributes_for(:issue_cause), format: "json" }; subject.reload
        }.to change(subject, :name)
        expect(response).to have_http_status :success
      end

      it "invalid" do
        expect {
          put :update, params: { id: subject, issue_cause: { name: '' }, format: "xml" }; subject.reload
        }.not_to change(subject, :name)
        expect(response).to have_http_status :unprocessable_entity
      end
    end

    describe "#destroy" do
      before :each do
        Role.non_member.add_permission! :view_issue_causes
      end
      subject! { FactoryBot.create(:issue_cause) }
      it { expect { delete :destroy, params: { id: subject } }.to change(IssueCause, :count).by -1 }

      it "record not found" do
        expect { delete :destroy, params: { id: "none", format: "json" } }.to change(IssueCause, :count).by 0
        expect(response).to have_http_status :not_found
      end
    end
  end

end
