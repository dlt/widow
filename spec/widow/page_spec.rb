require 'spec_helper'

describe Page do
  let(:page) do
    selectors = {
      forms: "form",
      links: "a"
    }

    Page.new(load_fixture("google.html"), selectors)
  end

  let(:parsed) do
    Nokogiri::HTML(load_fixture("google.html"))
  end

  it "should have create acessor methods based on the selectors options passed in the constructor" do
    page.links.to_s.should == parsed.css("a").to_s
    page.forms.to_s.should == parsed.css("form").to_s
  end
end

