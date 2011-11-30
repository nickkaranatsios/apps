/*
 * Author: Yasunobu Chiba
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


#include "ruby.h"
#include "authenticator.h"
#include "trema.h"


VALUE cAuthenticator;
static VALUE singleton_instance = Qnil;


/*
 * Searches the database for the given Ethernet address.
 *
 * @param [Mac] an Ethernet address represented as an instance of the class 
 *   Trema::Mac.
 *
 * @return [Boolean] true if Ethernet address is found otherwise false.
 */
static VALUE
rb_authenticate_mac( VALUE self, VALUE mac ) {
  UNUSED( self );

  VALUE mac_arr = rb_funcall( mac, rb_intern( "to_short" ), 0 );
  int i;
  uint8_t haddr[ OFP_ETH_ALEN ];
  for ( i = 0; i < RARRAY_LEN( mac_arr ); i++ ) {
    haddr[ i ] = ( uint8_t ) ( NUM2INT( RARRAY_PTR( mac_arr )[ i ] ) );
  }
  if ( !authenticate( haddr ) ) {
    return Qfalse;
  }
  return Qtrue;
}


static VALUE
new_instance_authenticator( VALUE self, VALUE file ) {
  UNUSED( self );
  if ( singleton_instance != Qnil ) {
    return singleton_instance;
  }
  singleton_instance = rb_funcall( rb_eval_string( "Authenticator" ), rb_intern( "new" ), 1, file );
  return singleton_instance;
}


static VALUE
initialize_authenticator( VALUE self, VALUE file ) {
  ( void )init_authenticator( StringValuePtr( file ) );
  return self;
}


void
Init_authenticator() {
  cAuthenticator = rb_define_class( "Authenticator", rb_cObject );
  rb_define_singleton_method( cAuthenticator, "new_instance", new_instance_authenticator, 1 );
  rb_define_private_method( cAuthenticator, "initialize", initialize_authenticator, 1 );
  rb_define_method( cAuthenticator, "authenticate_mac", rb_authenticate_mac, 1 );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */
