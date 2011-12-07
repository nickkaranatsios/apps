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


$LOAD_PATH << "../apps_backup/redirectable_routing_switch"


require "trema/router"
require "authenticator"
require "redirector"
require "redirectable-routing-switch-options"
require "authentication-filter"


class RedirectableRoutingSwitch < Trema::Controller
  include Router


  def start
    opts = RedirectableRoutingSwitchOptions.parse( ARGV )
    if opts.nil? 
      shutdown!
      exit
    end
    @authenticator = Authenticator.instance.init( opts.authorized_host_db )
    @redirector = Redirector.instance.init
    start_router( opts )
  end


  def packet_in datapath_id, message
    return unless validate_in_port datapath_id, message.in_port
    return if message.macda.is_multicast?
    @fdb.learn message.macsa, message.in_port, datapath_id
puts message.macsa
    if !@authenticator.authenticate_mac( message.macsa )
      # if the array list is empty call redirect otherwise skip redirection
      filtered = AuthenticationFilter.apply( message )
      if filtered.length == 0
puts "redirect"
        @redirector.redirect datapath_id, message
      end
    else
      if dest = @fdb.lookup( message.macda )
puts "make path"
        make_path datapath_id, message, dest
      else
puts "flood_packet"
        flood_packet datapath_id, message
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
