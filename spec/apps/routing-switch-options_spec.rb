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
require "routing_switch/routing-switch-options"


describe RoutingSwitchOptions, "default options" do 
 its ( :idle_timeout ) { should == 60 }
 its ( :discard_packet_in_duration ) { should == 1 }
end


describe RoutingSwitchOptions, "long format option: --idle-timeout" do
  subject{ RoutingSwitchOptions.parse( [ "--idle-timeout", "70" ] ) }
  its ( :idle_timeout ) { should == 70 }
end


describe RoutingSwitchOptions, "short format option: -i" do
  subject{ RoutingSwitchOptions.parse( [ "-i", "70" ] ) }
  its ( :idle_timeout ) { should == 70 }
end


describe RoutingSwitchOptions, "long format option: --packet-in-discard-duration" do
  subject{ RoutingSwitchOptions.parse( [ "--packet-in-discard-duration", "2" ] ) }
  its ( :discard_packet_in_duration ) { should == 2 }
end


describe RoutingSwitchOptions, "short format option: -d" do
  subject{ RoutingSwitchOptions.parse( [ "-d", "2" ] ) }
  its ( :discard_packet_in_duration ) { should == 2 }
end


describe RoutingSwitchOptions, "--invalid-option" do
  subject{ RoutingSwitchOptions.parse( [ "--invalid-option", "10" ] ) }
  expected_error = /.* --invalid-option/
  it "should raise error" do
    expect { subject }.to raise_error( expected_error )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
