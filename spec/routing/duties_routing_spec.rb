require "rails_helper"

RSpec.describe DutiesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/duties").to route_to("duties#index")
    end

    it "routes to #show" do
      expect(get: "/duties/1").to route_to("duties#show", id: "1")
    end


    it "routes to #create" do
      expect(post: "/duties").to route_to("duties#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/duties/1").to route_to("duties#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/duties/1").to route_to("duties#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/duties/1").to route_to("duties#destroy", id: "1")
    end
  end
end
