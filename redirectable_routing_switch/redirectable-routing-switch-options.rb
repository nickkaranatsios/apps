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


require "trema/model"


class RedirectableRoutingSwitchOptions < Model::Options
  def parse!( args ) 
    super
    args.options do | opts |
      opts.on( "-a",
        "--authorized-host-db  DB_FILE",
        :required,
        "Authorized host database file" ) do | file |
          @options[ :authorized_host_db ] = file
      end
      opts.on( "-i",
        "--idle-timeout TIMEOUT",
        "Idle timeout value for flow entry" ) do | t |
          @options[ :idle_timeout ] = t.to_i
      end
    end.parse!
    unless @options[ :authorized_host_db ]
      $stderr.puts "Mandatory option required: -a --authorized-host-db DB_FILE"
      return nil
    end
    self
  end


  def default_options
    {
      :idle_timeout => 60
    }
  end


  def idle_timeout
    @options[ :idle_timeout ]
  end


  def authorized_host_db
    @options[ :authorized_host_db ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
