/*
 * Author: Nick Karanatsios <nickkaranatsios@gmail.com>
 *
 * Copyright (C) 2008-2011 NEC Corporation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License, version 2, as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */


#include "redirector.h"
#include "ruby.h"
#include "trema.h"


VALUE cRedirector;
static VALUE singleton_instance = Qnil;


static VALUE
initialize_redirector( VALUE self ) {
  if ( !init_redirector() ) {
    rb_raise( rb_eRuntimeError, "Failed to initialize redirector" );
  }
  return self;
}

/*
 * Routes non-authorized packets via a tun device to a destination host.
 * If initializer called multiple times an already initialized instance
 * is returned.
 *
 * @overload initialize()
 *
 *   @example Redirector.new_instance
 *
 *   @raise [RuntimeError] if failed to initialize the tun device.
 *
 *   @return [Redirector] self
 *     an object that encapsulates this instance.
 */
static VALUE
new_instance_redirector( VALUE self ) {
  UNUSED( self );
  if ( singleton_instance != Qnil ) {
    return singleton_instance;
  }
  singleton_instance = rb_funcall( rb_eval_string( "Redirector" ), rb_intern( "new" ), 0 );
  return singleton_instance;
}


/*
 * Writes the unauthorized packet to a pre-configured tun device. The packet
 * could then forwarded to another host by using iptables.
 *
 * @param [Number] :datapath_id
 *   the message originator.
 *
 * @param [PacketIn] :message
 *   the message to redirect.
 *
 */
static VALUE
rb_redirect( VALUE self, VALUE datapath_id, VALUE message ) {
  packet_in *_packet_in;
  Data_Get_Struct( message, packet_in, _packet_in );
  redirect( NUM2ULL( datapath_id ), _packet_in->in_port, _packet_in->data );
  return self;
}


void 
Init_redirector() {
  cRedirector = rb_define_class( "Redirector", rb_cObject );
  rb_define_singleton_method( cRedirector, "new_instance", new_instance_redirector, 0 );
  rb_define_private_method( cRedirector, "initialize", initialize_redirector, 0 );
  rb_define_method( cRedirector, "redirect", rb_redirect, 2 );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */
