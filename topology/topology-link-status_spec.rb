$LOAD_PATH << "../trema/ruby"
$LOAD_PATH << "topology"

require "trema"
require "topology_client"


module TopologyClient
  describe TopologyLinkStatus, ".new" do 
    subject { TopologyLinkStatus.new }
    its ( :from_dpid ) { should == 0 }
    its ( :to_dpid ) { should == 0 }
    its ( :from_portno ) { should == 0 }
    its ( :status ) { should == 0 }
  end


  describe TopologyLinkStatus, ".new( ANY OPTION )" do
    subject { TopologyLinkStatus.new 123 }
    it "should raise ArgumentError" do
      expect { subject }.to raise_error( ArgumentError )
    end
  end
end
