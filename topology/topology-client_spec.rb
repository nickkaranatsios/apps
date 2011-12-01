$LOAD_PATH << "../trema/ruby"
$LOAD_PATH << "topology"

require "trema"
require "topology_client"
require "observer"


describe TopologyClient do
  before do
    class Foo
      include TopologyClient
    end
    @foo = Foo.new


    class MyObserver
      include Observable


      def initialize foo
        foo.add_observer self
      end


      def update
      end
    end
    @observer = MyObserver.new( @foo )
  end


  it "should respond to init_topology_client" do
    @foo.should respond_to( :init_topology_client )
  end


  it "should notifier observers of topology changes" do
    @observer.should_receive( :update ).once
    message = mock( "port status message" )
    @foo.topology_notifier message, :port
  end


  it "should raise if invalid topology notifier" do
    @obser
  end
end
