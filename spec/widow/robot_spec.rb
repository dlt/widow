require 'spec_helper'

describe Widow::Robot do
  let(:robot_class) do
    Class.new do
      include Widow::Robot
    end
  end

  let(:robot) do
    robot_class.new(root_url: "http://google.com")
  end

  it "should set the root_url upon initialization" do
    robot.root_url.should == "http://google.com"
  end

  it "should add an GET action to the actions stack" do
    robot.actions_stack.size.should be_zero

    robot.get "/" do |page|
      1
    end

    robot.actions_stack.size.should == 1
    robot.actions_stack.first[:method].should == :get

    robot.get "/foo" do |page|
      2
    end

    robot.actions_stack.size.should == 2
    robot.actions_stack.last[:method].should == :get
  end

  it "should add a POST action to the action stack" do
    robot.actions_stack.size.should be_zero
    robot.post "/post" do
    end
    robot.actions_stack.size.should == 1
    robot.actions_stack.first[:method].should == :post
  end

  it "should prepend return the url full path" do
    robot.full_path("/").should == robot.root_url + "/"
    robot.full_path("http://foo.bar").should == "http://foo.bar"
  end

end

