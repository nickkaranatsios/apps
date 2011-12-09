#
# Author: Nick Karanatsios <nickkaranatsios@gmail.com>
#
# Copyright (C) 2008-2011 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


require 'apps-spec-helper'


require "trema"
require "trema/model"


module Model
  describe SwitchDS, "port source adapter" do 
    class PortStatusMessage
      attr_reader :dpid, :port_no, :status, :external
      def initialize _dpid, _port_no, _status, _external
        @dpid, @port_no, @status, @external = _dpid, _port_no, _status, _external
      end
    end


    class LinkStatusMessage
      attr_reader :from_dpid, :from_portno, :to_dpid, :to_portno, :status
      def initialize _from_dpid, _from_portno, _to_dpid, _to_portno, _status
        @from_dpid, @from_portno, @to_dpid, @to_portno, @status = _from_dpid, _from_portno, _to_dpid, _to_portno, _status
      end
    end


    it "adds a port to a switch" do
      subject.process_port_status PortStatusMessage.new 0xe0, 1, 1, 1
      port_ds = subject.lookup_port( 0xe0, 1 )
      port_ds.port_no.should == 1
      port_ds.external_link.should be_true
    end


    it "adds multiple ports to a switch" do
      subject.process_port_status PortStatusMessage.new 0xe0, 1, 1, 0
      subject.process_port_status PortStatusMessage.new 0xe0, 2, 1, 0
      [ 1, 2 ].each do | p |
        port_ds = subject.lookup_port( 0xe0, p )
        port_ds.port_no.should == p
      end
    end


    it "adds the same port to multiple switches" do
      subject.process_port_status PortStatusMessage.new 0xe0, 1, 1, 0
      subject.process_port_status PortStatusMessage.new 0xe1, 1, 1, 0
      [ 0xe0, 0xe1 ].each do | dpid |
        port_ds = subject.lookup_port( dpid, 1 )
        port_ds.port_no.should == 1
      end
    end


    it "deletes a port when status down" do
      subject.process_port_status PortStatusMessage.new 0xe0, 1, 1, 0
      subject.process_port_status PortStatusMessage.new 0xe0, 1, 0, 0
      subject.lookup_port( 0xe0, 1 ).should be_nil
    end


    it "sets the switch's link to specified status" do
      subject.process_port_status PortStatusMessage.new 0xe0, 1, 1, 0
      subject.process_link_status LinkStatusMessage.new 0xe0, 1, 0, 0, 0
      port_ds = subject.lookup_port( 0xe0, 1 )
      port_ds.switch_to_switch_link.should be_false
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
