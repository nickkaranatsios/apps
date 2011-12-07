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
require "redirectable_routing_switch/authentication-filter"


describe AuthenticationFilter do 
  def set_disallow
    packet_in = PacketIn.new
    packet_in.stub!( :udp_src_port ).and_return( 1 )
    packet_in.stub!( :udp_dst_port ).and_return( 1 )
    packet_in.stub!( :tcp_src_port).and_return( 5555 )
    packet_in.stub!( :tcp_dst_port).and_return( 9999 )
    packet_in.stub!( :arp? ).and_return( false )
    packet_in
  end


  def set_allow
    packet_in = PacketIn.new
    packet_in.stub!( :udp_src_port ).and_return( 67 )
    packet_in.stub!( :udp_dst_port ).and_return( 68 )
    packet_in.stub!( :tcp_src_port).and_return( 53 )
    packet_in.stub!( :tcp_dst_port).and_return( 9999 )
    packet_in.stub!( :arp? ).and_return( true )
    packet_in
  end
  

  def when_allowed
    packet_in = set_allow
    yield packet_in
  end


  def when_not_allowed
    packet_in = set_disallow
    yield set_disallow
  end


  it "should pass authentication if allowed" do
    when_allowed do | packet_in |
      AuthenticationFilter.apply( packet_in ).should_not be_empty
    end
  end


  it "should failed authentication if not allowed" do
    when_not_allowed do | packet_in |
      AuthenticationFilter.apply( packet_in ).should be_empty
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
