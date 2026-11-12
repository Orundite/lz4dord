module lz4dord.lz4frame_static;

/* lz4dord.lz4frame - FFI Dlang LZ4FrameStatic 1.11.1 (LZ4 auto-framing library)
 * SPDX-License-Identifier: MIT AND BSD-2-Clause
 *
 * Copyright (c) 2026 Orundite
 * D bindings: MIT License, see LICENSE.
 * Portions derived from LZ4's lz4frame_static.h (declarations and documentation
 * comments) remain under the BSD 2-Clause License reproduced below.
 *
 * This: https://github.com/Orundite/lz4dord
 */
 
//Original lz4frame_static.h (LZ4) header text:
/*
   LZ4 auto-framing library
   Header File for static linking only
   Copyright (c) Yann Collet. All rights reserved.

   BSD 2-Clause License (http://www.opensource.org/licenses/bsd-license.php)

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

       * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above
   copyright notice, this list of conditions and the following disclaimer
   in the documentation and/or other materials provided with the
   distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

   You can contact the author at :
   - LZ4 source repository : https://github.com/lz4/lz4
   - LZ4 public forum : https://groups.google.com/forum/#!forum/lz4c
*/

//ifn LZ4FRAME_STATIC_H_0398209384

/* The declarations that formerly were made here have been merged into
 * lz4frame.h, protected by the LZ4F_STATIC_LINKING_ONLY macro. Going forward,
 * it is recommended to simply include that header directly.
 */

//define LZ4F_STATIC_LINKING_ONLY
public import lz4dord.lz4frame;

//end /* LZ4FRAME_STATIC_H_0398209384 */
