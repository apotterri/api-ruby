require 'spec_helper'
require 'standard_methods_helper'

describe Conjur::API, api: :dummy do
  describe '#create_user' do
    it_should_behave_like 'standard_create with', :user, nil, login: 'login', other: true do
      let(:invoke) { api.create_user 'login', other: true }
    end
  end

  describe 'user#update' do
    let(:userid) { "alice@wonderland" }
    it "PUTs to /users/:id?uidnumber=:uidnumber" do
      expect_request(
        method: :put,
        url: "#{core_host}/users/#{api.fully_escape(userid)}",
        headers: credentials[:headers],
        payload: { uidnumber: 12345 }
       )
      api.user(userid).update(uidnumber: 12345)
    end
    
  end

  describe "find_users" do

    let(:search_parameters) { {uidnumber: 12345} }
    let(:search_result)     { ["someuser"].to_json }
    
    it "GETs /users/search with appropriate options, and returns parsed JSON response" do
      expect_request(
        method: :get,  
        url: "#{core_host}/users/search?uidnumber=12345",
        headers: credentials[:headers]
      ).and_return search_result

      parsed = double()

      expect(JSON).to receive(:parse).with(search_result).and_return(parsed)

      expect(api.find_users(search_parameters)).to eq(parsed)
    end
  end

  describe '#user' do
    it_should_behave_like 'standard_show with', :user, :login do
      let(:invoke) { api.user :login }
    end
  end
end
