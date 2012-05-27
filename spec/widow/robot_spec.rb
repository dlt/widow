require 'spec_helper'

describe Robot do
  let(:robot_class) do
    Class.new do
      include Robot
    end
  end

  let(:robot) do
    robot_class.new({
      root_url: "http://google.com",
      interval_between_requests: 0.01
    })
  end

  it "should set the root_url upon initialization" do
    robot.root_url.should == "http://google.com"
  end

  it "should add an GET action to the request stack" do
    robot.request_stack.size.should be_zero

    robot.get "/" do |page|
      1
    end

    robot.request_stack.size.should == 1
    robot.request_stack.first[:method].should == :get

    robot.get "/foo" do |page|
      2
    end

    robot.request_stack.size.should == 2
    robot.request_stack.last[:method].should == :get
  end

  it "should add a POST action to the action stack" do
    robot.request_stack.size.should be_zero
    robot.post "/post" do
    end
    robot.request_stack.size.should == 1
    robot.request_stack.first[:method].should == :post
  end

  it "should prepend return the url full path" do
    robot.full_path("/").should == robot.root_url + "/"
    robot.full_path("http://foo.bar").should == "http://foo.bar"
  end

  describe "when running" do
    it "should raise config exception if :interval_between_requests option isn't set" do
      lambda {
        robot = robot_class.new({})
      }.should raise_error(ArgumentError)

      lambda {
        robot = robot_class.new interval_between_requests: 0.1
      }.should_not raise_error
    end

    it "should yield an instance of Widow::Page" do
      robot.get "/search?q=concurrency" do |page|
        page.should be_instance Page
      end

      VCR.use_cassette("default_google_search", serialize_with: :json) do
        robot.run
      end
    end
  end

end

