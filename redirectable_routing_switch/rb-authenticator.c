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


#include "trema.h"
#include "ruby.h"
#include "authenticator.h"


VALUE cAuthenticator;
static uint8_t initialized = 0;



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
rb_init_authenticator( VALUE self, VALUE file ) {
  if ( initialized ) {
    return cAuthenticator;
  }
  ( void )init_authenticator( StringValuePtr( file ) );
  initialized = 1;
  return self;
}


void
Init_authenticator() {
  cAuthenticator = rb_define_class( "Authenticator", rb_cObject );
  rb_define_method( cAuthenticator, "initialize", rb_init_authenticator, 1 );
  rb_define_method( cAuthenticator, "authenticate_mac", rb_authenticate_mac, 1 );
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */
