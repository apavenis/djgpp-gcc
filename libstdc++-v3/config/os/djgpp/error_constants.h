// Specific definitions for DJGPP platform  -*- C++ -*-

// Copyright (C) 2010-2024 Free Software Foundation, Inc.
//
// This file is part of the GNU ISO C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// Under Section 7 of GPL version 3, you are granted additional
// permissions described in the GCC Runtime Library Exception, version
// 3.1, as published by the Free Software Foundation.

// You should have received a copy of the GNU General Public License and
// a copy of the GCC Runtime Library Exception along with this program;
// see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
// <http://www.gnu.org/licenses/>.

/** @file bits/error_constants.h
 *  This is an internal header file, included by other library headers.
 *  Do not attempt to use it directly. @headername{system_error}
 */

#ifndef _GLIBCXX_ERROR_CONSTANTS
#define _GLIBCXX_ERROR_CONSTANTS 1

#include <bits/c++config.h>
#include <cerrno>

// Include Watt-32 errno list, if present
#if defined __has_include && __has_include(<sys/werrno.h>)
#include <sys/werrno.h>
#endif

#ifndef EOPNOTSUPP
// Use same value as in wat3222br6.zip file net/watt/sys/djgpp.err
#define EOPNOTSUPP 52
#endif

#ifndef ENOTSUP
#define ENOTSUP 101
#endif

namespace std _GLIBCXX_VISIBILITY(default)
{
_GLIBCXX_BEGIN_NAMESPACE_VERSION

  enum class errc
    {
#ifdef EAFNOSUPPORT
      address_family_not_supported = 		EAFNOSUPPORT,
#endif

#ifdef EADDRINUSE
      address_in_use = 				EADDRINUSE,
#endif

#ifdef EADDRNOTAVAIL
      address_not_available = 			EADDRNOTAVAIL,
#endif

#ifdef EISCONN
      already_connected = 			EISCONN,
#endif

      argument_list_too_long = 			E2BIG,
      argument_out_of_domain = 			EDOM,
      bad_address = 				EFAULT,
      bad_file_descriptor = 			EBADF,

#ifdef EBADMSG
      bad_message = 				EBADMSG,
#endif

      broken_pipe = 				EPIPE,

#ifdef ECONNABORTED
      connection_aborted = 			ECONNABORTED,
#endif

#ifdef EALREADY
      connection_already_in_progress = 		EALREADY,
#endif

#ifdef ECONNREFUSED
      connection_refused = 			ECONNREFUSED,
#endif

#ifdef ECONNRESET
      connection_reset = 			ECONNRESET,
#endif

      cross_device_link = 			EXDEV,

#ifdef EDESTADDRREQ
      destination_address_required = 		EDESTADDRREQ,
#endif

      device_or_resource_busy = 		EBUSY,
      directory_not_empty = 			ENOTEMPTY,
      executable_format_error = 		ENOEXEC,
      file_exists = 	       			EEXIST,
      file_too_large = 				EFBIG,
      filename_too_long = 			ENAMETOOLONG,
      function_not_supported = 			ENOSYS,

#ifdef EHOSTUNREACH
      host_unreachable = 			EHOSTUNREACH,
#endif

#ifdef EIDRM
      identifier_removed = 			EIDRM,
#endif

      illegal_byte_sequence = 			EILSEQ,
      inappropriate_io_control_operation = 	ENOTTY,
      interrupted = 				EINTR,
      invalid_argument = 			EINVAL,
      invalid_seek = 				ESPIPE,
      io_error = 				EIO,
      is_a_directory = 				EISDIR,

#ifdef EMSGSIZE
      message_size = 				EMSGSIZE,
#endif

#ifdef ENETDOWN
      network_down = 				ENETDOWN,
#endif

#ifdef ENETRESET
      network_reset = 				ENETRESET,
#endif

#ifdef ENETUNREACH
      network_unreachable = 			ENETUNREACH,
#endif

#ifdef ENOBUFS
      no_buffer_space = 			ENOBUFS,
#endif

      no_child_process = 			ECHILD,

#ifdef ENOLINK
      no_link = 				ENOLINK,
#endif

      no_lock_available = 			ENOLCK,

#ifdef ENODATA
      no_message_available = 			ENODATA,
#endif

#ifdef ENOMSG
      no_message = 				ENOMSG,
#endif

#ifdef ENOPROTOOPT
      no_protocol_option = 			ENOPROTOOPT,
#endif

      no_space_on_device = 			ENOSPC,

#ifdef ENOSR
      no_stream_resources = 			ENOSR,
#endif

      no_such_device_or_address = 		ENXIO,
      no_such_device = 				ENODEV,
      no_such_file_or_directory = 		ENOENT,
      no_such_process = 			ESRCH,
      not_a_directory = 			ENOTDIR,

#ifdef ENOTSOCK
      not_a_socket = 				ENOTSOCK,
#endif

#ifdef ENOSTR
      not_a_stream = 				ENOSTR,
#endif

#ifdef ENOTCONN
      not_connected = 				ENOTCONN,
#endif

      not_enough_memory = 			ENOMEM,

#ifdef ENOTSUP
      not_supported = 				ENOTSUP,
#endif

#ifdef ECANCELED
      operation_canceled = 			ECANCELED,
#endif

#ifdef EINPROGRESS
      operation_in_progress = 			EINPROGRESS,
#endif

      operation_not_permitted = 		EPERM,
      operation_not_supported = 		EOPNOTSUPP,

#ifdef EWOULDBLOCK
      operation_would_block = 			EWOULDBLOCK,
#endif

#ifdef EOWNERDEAD
      owner_dead = 				EOWNERDEAD,
#endif

      permission_denied = 			EACCES,

#ifdef EPROTO
      protocol_error = 				EPROTO,
#endif

#ifdef EPROTONOSUPPORT
      protocol_not_supported = 			EPROTONOSUPPORT,
#endif

      read_only_file_system = 			EROFS,
      resource_deadlock_would_occur = 		EDEADLK,
      resource_unavailable_try_again = 		EAGAIN,
      result_out_of_range = 			ERANGE,

#ifdef ENOTRECOVERABLE
      state_not_recoverable = 			ENOTRECOVERABLE,
#endif

#ifdef ETIME
      stream_timeout = 				ETIME,
#endif

#ifdef ETXTBSY
      text_file_busy = 				ETXTBSY,
#endif

#ifdef ETIMEDOUT
      timed_out = 				ETIMEDOUT,
#endif

      too_many_files_open_in_system = 		ENFILE,
      too_many_files_open = 			EMFILE,
      too_many_links = 				EMLINK,
      too_many_symbolic_link_levels = 		ELOOP,

#ifdef EOVERFLOW
      value_too_large = 			EOVERFLOW,
#endif

#ifdef EPROTOTYPE
      wrong_protocol_type = 			EPROTOTYPE
#endif
    };

_GLIBCXX_END_NAMESPACE_VERSION
} // namespace

#endif
