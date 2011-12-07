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
require "redirectable_routing_switch/redirectable-routing-switch-options"


describe RedirectableRoutingSwitchOptions, "default options" do 
 its ( :idle_timeout ) { should == 60 }
end


describe RedirectableRoutingSwitchOptions, "long format option: --authorized-host-db" do
  subject{ RedirectableRoutingSwitchOptions.parse( [ "--authorized-host-db", "authorized-host.db" ] ) }
  its ( :authorized_host_db ) { should == "authorized-host.db" }
end


describe RedirectableRoutingSwitchOptions, "short format option: -a" do
  subject{ RedirectableRoutingSwitchOptions.parse( [ "-a", "authorized-host.db" ] ) }
  its ( :authorized_host_db ) { should == "authorized-host.db" }
end


describe RedirectableRoutingSwitchOptions, "long format option: --idle-timeout" do
  subject{ RedirectableRoutingSwitchOptions.parse( [ "-a", "authorized-host.db", "--idle-timeout", "70" ] ) }
  its ( :idle_timeout ) { should == 70 }
end


describe RedirectableRoutingSwitchOptions, "short format option: -i" do
  subject{ RedirectableRoutingSwitchOptions.parse( [ "-a", "authorized-host-db", "-i", "70" ] ) }
  its ( :idle_timeout ) { should == 70 }
end


describe RedirectableRoutingSwitchOptions, "required option missing" do
  it "should print a usage message" do
    $stderr.should_receive( :puts ).with( "Mandatory option required: -a --authorized-host-db DB_FILE" )
    RedirectableRoutingSwitchOptions.parse( [ "-i", "10" ] )
  end
end


describe RedirectableRoutingSwitchOptions, "--invalid-option" do
  subject{ RedirectableRoutingSwitchOptions.parse( [ "--invalid-option", "10" ] ) }
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
