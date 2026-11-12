module lz4dord.lz4;

/* lz4dord.lz4 - FFI Dlang LZ4 1.11.1 (Fast LZ compression algorithm)
 * SPDX-License-Identifier: MIT AND BSD-2-Clause
 *
 * Copyright (c) 2026 Orundite
 * D bindings: MIT License, see LICENSE.
 * Portions derived from LZ4's lz4.h (declarations and documentation
 * comments) remain under the BSD 2-Clause License reproduced below.
 *
 * This: https://github.com/Orundite/lz4dord
 */

//Original lz4.h (LZ4) header text:
/*
 *  LZ4 - Fast LZ compression algorithm
 *  Header File
 *  Copyright (c) Yann Collet. All rights reserved.

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
    - LZ4 homepage : http://www.lz4.org
    - LZ4 source repository : https://github.com/lz4/lz4
*/

//API
extern (C) nothrow @nogc
{
//ifn LZ4_H_2983827168210

//Version
enum LZ4_VERSION_MAJOR = 1;    /* for breaking interface changes  */
enum LZ4_VERSION_MINOR = 11;   /* for new (non-breaking) interface capabilities */
enum LZ4_VERSION_RELEASE = 1;  /* for tweaks, bug-fixes, or development */


enum LZ4_VERSION_NUMBER =
    LZ4_VERSION_MAJOR * 10_000 +
    LZ4_VERSION_MINOR * 100 +
    LZ4_VERSION_RELEASE;

enum LZ4_LIB_VERSION = "1.11.1";
enum LZ4_VERSION_STRING = LZ4_LIB_VERSION;

int LZ4_versionNumber();  /**< library version number; useful to check dll version; requires v1.3.0+ */
const(char)* LZ4_versionString();   /**< library version string; useful to check dll version; requires v1.7.5+ */

/*-************************************
*  Tuning memory usage
**************************************/
/*!
 * LZ4_MEMORY_USAGE :
 * Can be selected at compile time, by setting LZ4_MEMORY_USAGE.
 * Memory usage formula : N->2^N Bytes (examples : 10 -> 1KB; 12 -> 4KB ; 16 -> 64KB; 20 -> 1MB)
 * Increasing memory usage improves compression ratio, generally at the cost of speed.
 * Reduced memory usage may improve speed at the cost of ratio, thanks to better cache locality.
 * Default value is 14, for 16KB, which nicely fits into most L1 caches.
 */
enum LZ4_MEMORY_USAGE_MIN     = 10;
enum LZ4_MEMORY_USAGE_DEFAULT = 14;
enum LZ4_MEMORY_USAGE_MAX     = 20;

enum LZ4_MEMORY_USAGE = LZ4_MEMORY_USAGE_DEFAULT;


//Simple Functions

/*! LZ4_compress_default() :
 *  Compresses 'srcSize' bytes from buffer 'src'
 *  into already allocated 'dst' buffer of size 'dstCapacity'.
 *  Compression is guaranteed to succeed if 'dstCapacity' >= LZ4_compressBound(srcSize).
 *  It also runs faster, so it's a recommended setting.
 *  If the function cannot compress 'src' into a more limited 'dst' budget,
 *  compression stops *immediately*, and the function result is zero.
 *  In which case, 'dst' content is undefined (invalid).
 *      srcSize : max supported value is LZ4_MAX_INPUT_SIZE.
 *      dstCapacity : size of buffer 'dst' (which must be already allocated)
 *     @return  : the number of bytes written into buffer 'dst' (necessarily <= dstCapacity)
 *                or 0 if compression fails
 * Note : This function is protected against buffer overflow scenarios (never writes outside 'dst' buffer, nor read outside 'source' buffer).
 */
int LZ4_compress_default(
        const(char)* src,
        char* dst,
        int srcSize,
        int dstCapacity
    );

/*! LZ4_decompress_safe() :
 * @compressedSize : is the exact complete size of the compressed block.
 * @dstCapacity : is the size of destination buffer (which must be already allocated),
 *                presumed an upper bound of decompressed size.
 * @return : the number of bytes decompressed into destination buffer (necessarily <= dstCapacity),
 *           or a negative error code (v1.11.0+) :
 *           -1 : generic error : malformed or truncated input, or invalid parameters
 *           -2 : decoded data doesn't fit into dstCapacity : buffer too small, or corrupted input
 *           -3 : data references bytes before the start of output : missing or wrong dictionary, or corrupted input
 *           Any negative value is an error : more specific codes may be added in future versions.
 * Note 1 : This function is protected against malicious data packets :
 *          it will never writes outside 'dst' buffer, nor read outside 'source' buffer,
 *          even if the compressed block is maliciously modified to order the decoder to do these actions.
 *          In such case, the decoder stops immediately, and considers the compressed block malformed.
 * Note 2 : compressedSize and dstCapacity must be provided to the function, the compressed block does not contain them.
 *          The implementation is free to send / store / derive this information in whichever way is most beneficial.
 *          If there is a need for a different format which bundles together both compressed data and its metadata, consider looking at lz4frame.h instead.
 */
    int LZ4_decompress_safe(
        const(char)* src,
        char* dst,
        int compressedSize,
        int dstCapacity
    );

/*-************************************
*  Advanced Functions
**************************************/
/*! LZ4_compressBound() :
    Provides the maximum size that LZ4 compression may output in a "worst case" scenario (input data not compressible)
    This function is primarily useful for memory allocation purposes (destination buffer size).
    Macro LZ4_COMPRESSBOUND() is also provided for compilation-time evaluation (stack memory allocation for example).
    Note that LZ4_compress_default() compresses faster when dstCapacity is >= LZ4_compressBound(srcSize)
        inputSize  : max supported value is LZ4_MAX_INPUT_SIZE
        return : maximum output size in a "worst case" scenario
              or 0, if input size is incorrect (too large or negative)
*/
//Advanced Functions
enum LZ4_MAX_INPUT_SIZE = 0x7E000000;

enum int LZ4_COMPRESSBOUND(int isize) = cast(uint)isize > cast(uint)LZ4_MAX_INPUT_SIZE
        ? 0
        : isize + (isize / 255) + 16;

  int LZ4_compressBound(int inputSize);

/*! LZ4_compress_fast() :
    Same as LZ4_compress_default(), but allows selection of "acceleration" factor.
    The larger the acceleration value, the faster the algorithm, but also the lesser the compression.
    It's a trade-off. It can be fine tuned, with each successive value providing roughly +~3% to speed.
    An acceleration value of "1" is the same as regular LZ4_compress_default()
    Values <= 0 will be replaced by LZ4_ACCELERATION_DEFAULT (currently == 1, see LZ4_STATIC_LINKING_ONLY section).
    Values > LZ4_ACCELERATION_MAX will be replaced by LZ4_ACCELERATION_MAX (currently == 65537, see LZ4_STATIC_LINKING_ONLY section).
*/
  int LZ4_compress_fast (const(char)* src, char* dst, int srcSize, int dstCapacity, int acceleration);


/*! LZ4_compress_fast_extState() :
 *  Same as LZ4_compress_fast(), using an externally allocated memory space for its state.
 *  Use LZ4_sizeofState() to know how much memory must be allocated,
 *  and allocate it on 8-bytes boundaries (using `malloc()` typically).
 *  Then, provide this buffer as `void* state` to compression function.
 */
  int LZ4_sizeofState();
  int LZ4_compress_fast_extState (void* state, const(char)* src, char* dst, int srcSize, int dstCapacity, int acceleration);

/*! LZ4_compress_destSize() :
 *  Reverse the logic : compresses as much data as possible from 'src' buffer
 *  into already allocated buffer 'dst', of size >= 'dstCapacity'.
 *  This function either compresses the entire 'src' content into 'dst' if it's large enough,
 *  or fill 'dst' buffer completely with as much data as possible from 'src'.
 *  note: acceleration parameter is fixed to "default".
 *
 * *srcSizePtr : in+out parameter. Initially contains size of input.
 *               Will be modified to indicate how many bytes where read from 'src' to fill 'dst'.
 *               New value is necessarily <= input value.
 * @return : Nb bytes written into 'dst' (necessarily <= dstCapacity)
 *           or 0 if compression fails.
 *
 * Note : 'targetDstSize' must be >= 1, because it's the smallest valid lz4 payload.
 *
 * Note 2:from v1.8.2 to v1.9.1, this function had a bug (fixed in v1.9.2+):
 *        the produced compressed content could, in rare circumstances,
 *        require to be decompressed into a destination buffer
 *        larger by at least 1 byte than decompressesSize.
 *        If an application uses `LZ4_compress_destSize()`,
 *        it's highly recommended to update liblz4 to v1.9.2 or better.
 *        If this can't be done or ensured,
 *        the receiving decompression function should provide
 *        a dstCapacity which is > decompressedSize, by at least 1 byte.
 *        See https://github.com/lz4/lz4/issues/859 for details
 */
  int LZ4_compress_destSize(const(char)* src, char* dst, int* srcSizePtr, int targetDstSize);

/*! LZ4_decompress_safe_partial() :
 *  Decompress an LZ4 compressed block, of size 'srcSize' at position 'src',
 *  into destination buffer 'dst' of size 'dstCapacity'.
 *  Up to 'targetOutputSize' bytes will be decoded.
 *  The function stops decoding on reaching this objective.
 *  This can be useful to boost performance
 *  whenever only the beginning of a block is required.
 *
 * @return : the number of bytes decoded in `dst` (necessarily <= targetOutputSize)
 *           or a negative error code (see LZ4_decompress_safe()), never -2.
 *
 *  Note 1 : @return can be < targetOutputSize, if compressed block contains less data.
 *
 *  Note 2 : targetOutputSize must be <= dstCapacity
 *
 *  Note 3 : this function effectively stops decoding on reaching targetOutputSize,
 *           so dstCapacity is kind of redundant.
 *           This is because in older versions of this function,
 *           decoding operation would still write complete sequences.
 *           Therefore, there was no guarantee that it would stop writing at exactly targetOutputSize,
 *           it could write more bytes, though only up to dstCapacity.
 *           Some "margin" used to be required for this operation to work properly.
 *           Thankfully, this is no longer necessary.
 *           The function nonetheless keeps the same signature, in an effort to preserve API compatibility.
 *
 *  Note 4 : If srcSize is the exact size of the block,
 *           then targetOutputSize can be any value,
 *           including larger than the block's decompressed size.
 *           The function will, at most, generate block's decompressed size.
 *
 *  Note 5 : If srcSize is _larger_ than block's compressed size,
 *           then targetOutputSize **MUST** be <= block's decompressed size.
 *           Otherwise, *silent corruption will occur*.
 */
  int LZ4_decompress_safe_partial (const(char)* src, char* dst, int srcSize, int targetOutputSize, int dstCapacity);


/*-*********************************************
*  Streaming Compression Functions
***********************************************/
/* incomplete type (defined later) */
alias LZ4_stream_t = LZ4_stream_u;

/*!
 Note about RC_INVOKED

 - RC_INVOKED is predefined symbol of rc.exe (the resource compiler which is part of MSVC/Visual Studio).
   https://docs.microsoft.com/en-us/windows/win32/menurc/predefined-macros

 - Since rc.exe is a legacy compiler, it truncates long symbol (> 30 chars)
   and reports warning "RC4011: identifier truncated".

 - To eliminate the warning, we surround long preprocessor symbol with
   "#if !defined(RC_INVOKED) ... #endif" block that means
   "skip this block when rc.exe is trying to read it".
*/
    LZ4_stream_t* LZ4_createStream();

    int LZ4_freeStream(LZ4_stream_t* streamPtr);

/*! LZ4_resetStream_fast() : v1.9.0+
 *  Use this to prepare an LZ4_stream_t for a new chain of dependent blocks
 *  (e.g., LZ4_compress_fast_continue()).
 *
 *  An LZ4_stream_t must be initialized once before usage.
 *  This is automatically done when created by LZ4_createStream().
 *  However, should the LZ4_stream_t be simply declared on stack (for example),
 *  it's necessary to initialize it first, using LZ4_initStream().
 *
 *  After init, start any new stream with LZ4_resetStream_fast().
 *  A same LZ4_stream_t can be re-used multiple times consecutively
 *  and compress multiple streams,
 *  provided that it starts each new stream with LZ4_resetStream_fast().
 *
 *  LZ4_resetStream_fast() is much faster than LZ4_initStream(),
 *  but is not compatible with memory regions containing garbage data.
 *
 *  Note: it's only useful to call LZ4_resetStream_fast()
 *        in the context of streaming compression.
 *        The *extState* functions perform their own resets.
 *        Invoking LZ4_resetStream_fast() before is redundant, and even counterproductive.
 */
void LZ4_resetStream_fast (LZ4_stream_t* streamPtr);

/*! LZ4_loadDict() :
 *  Use this function to reference a static dictionary into LZ4_stream_t.
 *  The dictionary must remain available during compression.
 *  LZ4_loadDict() triggers a reset, so any previous data will be forgotten.
 *  The same dictionary will have to be loaded on decompression side for successful decoding.
 *  Dictionary are useful for better compression of small data (KB range).
 *  While LZ4 itself accepts any input as dictionary, dictionary efficiency is also a topic.
 *  When in doubt, employ the Zstandard's Dictionary Builder.
 *  Loading a size of 0 is allowed, and is the same as reset.
 * @return : loaded dictionary size, in bytes (note: only the last 64 KB are loaded)
 */
int LZ4_loadDict (LZ4_stream_t* streamPtr, const(char)* dictionary, int dictSize);

/*! LZ4_loadDictSlow() : v1.10.0+
 *  Same as LZ4_loadDict(),
 *  but uses a bit more cpu to reference the dictionary content more thoroughly.
 *  This is expected to slightly improve compression ratio.
 *  The extra-cpu cost is likely worth it if the dictionary is re-used across multiple sessions.
 * @return : loaded dictionary size, in bytes (note: only the last 64 KB are loaded)
 */
int LZ4_loadDictSlow(LZ4_stream_t* streamPtr, const(char)* dictionary, int dictSize);

/*! LZ4_attach_dictionary() : stable since v1.10.0
 *
 *  This allows efficient re-use of a static dictionary multiple times.
 *
 *  Rather than re-loading the dictionary buffer into a working context before
 *  each compression, or copying a pre-loaded dictionary's LZ4_stream_t into a
 *  working LZ4_stream_t, this function introduces a no-copy setup mechanism,
 *  in which the working stream references @dictionaryStream in-place.
 *
 *  Several assumptions are made about the state of @dictionaryStream.
 *  Currently, only states which have been prepared by LZ4_loadDict() or
 *  LZ4_loadDictSlow() should be expected to work.
 *
 *  Alternatively, the provided @dictionaryStream may be NULL,
 *  in which case any existing dictionary stream is unset.
 *
 *  If a dictionary is provided, it replaces any pre-existing stream history.
 *  The dictionary contents are the only history that can be referenced and
 *  logically immediately precede the data compressed in the first subsequent
 *  compression call.
 *
 *  The dictionary will only remain attached to the working stream through the
 *  first compression call, at the end of which it is cleared.
 * @dictionaryStream stream (and source buffer) must remain in-place / accessible / unchanged
 *  through the completion of the compression session.
 *
 *  Note: there is no equivalent LZ4_attach_*() method on the decompression side
 *  because there is no initialization cost, hence no need to share the cost across multiple sessions.
 *  To decompress LZ4 blocks using dictionary, attached or not,
 *  just employ the regular LZ4_setStreamDecode() for streaming,
 *  or the stateless LZ4_decompress_safe_usingDict() for one-shot decompression.
 */
void
LZ4_attach_dictionary(LZ4_stream_t* workingStream,
                const(LZ4_stream_t)* dictionaryStream);

/*! LZ4_compress_fast_continue() :
 *  Compress 'src' content using data from previously compressed blocks, for better compression ratio.
 * 'dst' buffer must be already allocated.
 *  If dstCapacity >= LZ4_compressBound(srcSize), compression is guaranteed to succeed, and runs faster.
 *
 * @return : size of compressed block
 *           or 0 if there is an error (typically, cannot fit into 'dst').
 *
 *  Note 1 : Each invocation to LZ4_compress_fast_continue() generates a new block.
 *           Each block has precise boundaries.
 *           Each block must be decompressed separately, calling LZ4_decompress_*() with relevant metadata.
 *           It's not possible to append blocks together and expect a single invocation of LZ4_decompress_*() to decompress them together.
 *
 *  Note 2 : The previous 64KB of source data is __assumed__ to remain present, unmodified, at same address in memory !
 *
 *  Note 3 : When input is structured as a double-buffer, each buffer can have any size, including < 64 KB.
 *           Make sure that buffers are separated, by at least one byte.
 *           This construction ensures that each block only depends on previous block.
 *
 *  Note 4 : If input buffer is a ring-buffer, it can have any size, including < 64 KB.
 *
 *  Note 5 : After an error, the stream status is undefined (invalid), it can only be reset or freed.
 */
int LZ4_compress_fast_continue (LZ4_stream_t* streamPtr, const(char)* src, char* dst, int srcSize, int dstCapacity, int acceleration);

/*! LZ4_saveDict() :
 *  If last 64KB data cannot be guaranteed to remain available at its current memory location,
 *  save it into a safer place (char* safeBuffer).
 *  This is schematically equivalent to a memcpy() followed by LZ4_loadDict(),
 *  but is much faster, because LZ4_saveDict() doesn't need to rebuild tables.
 * @return : saved dictionary size in bytes (necessarily <= maxDictSize), or 0 if error.
 */
int LZ4_saveDict (LZ4_stream_t* streamPtr, char* safeBuffer, int maxDictSize);


/*-**********************************************
*  Streaming Decompression Functions
*  Bufferless synchronous API
************************************************/
/* tracking context */
alias LZ4_streamDecode_t = LZ4_streamDecode_u;
/*! LZ4_createStreamDecode() and LZ4_freeStreamDecode() :
 *  creation / destruction of streaming decompression tracking context.
 *  A tracking context can be re-used multiple times.
 */

LZ4_streamDecode_t* LZ4_createStreamDecode();
int LZ4_freeStreamDecode (LZ4_streamDecode_t* LZ4_stream);

/*! LZ4_setStreamDecode() :
 *  An LZ4_streamDecode_t context can be allocated once and re-used multiple times.
 *  Use this function to start decompression of a new stream of blocks.
 *  A dictionary can optionally be set. Use NULL or size 0 for a reset order.
 *  Dictionary is presumed stable : it must remain accessible and unmodified during next decompression.
 * @return : 1 if OK, 0 if error
 */
int LZ4_setStreamDecode (LZ4_streamDecode_t* LZ4_streamDecode, const(char)* dictionary, int dictSize);

/*! LZ4_decoderRingBufferSize() : v1.8.2+
 *  Note : in a ring buffer scenario (optional),
 *  blocks are presumed decompressed next to each other
 *  up to the moment there is not enough remaining space for next block (remainingSize < maxBlockSize),
 *  at which stage it resumes from beginning of ring buffer.
 *  When setting such a ring buffer for streaming decompression,
 *  provides the minimum size of this ring buffer
 *  to be compatible with any source respecting maxBlockSize condition.
 * @return : minimum ring buffer size,
 *           or 0 if there is an error (invalid maxBlockSize).
 */
int LZ4_decoderRingBufferSize(int maxBlockSize);
size_t LZ4_DECODER_RING_BUFFER_SIZE(size_t maxBlockSize) /* for static allocation; maxBlockSize presumed valid */
    pure nothrow @nogc //Macros C
{
    return 65536 + 64 + maxBlockSize;
} 

/*! LZ4_decompress_safe_continue() :
 *  This decoding function allows decompression of consecutive blocks in "streaming" mode.
 *  The difference with the usual independent blocks is that
 *  new blocks are allowed to find references into former blocks.
 *  A block is an unsplittable entity, and must be presented entirely to the decompression function.
 *  LZ4_decompress_safe_continue() only accepts one block at a time.
 *  It's modeled after `LZ4_decompress_safe()` and behaves similarly.
 *
 * @LZ4_streamDecode : decompression state, tracking the position in memory of past data
 * @compressedSize : exact complete size of one compressed block.
 * @dstCapacity : size of destination buffer (which must be already allocated),
 *                must be an upper bound of decompressed size.
 * @return : number of bytes decompressed into destination buffer (necessarily <= dstCapacity)
 *           or a negative error code (see LZ4_decompress_safe()).
 *
 *  The last 64KB of previously decoded data *must* remain available and unmodified
 *  at the memory position where they were previously decoded.
 *  If less than 64KB of data has been decoded, all the data must be present.
 *
 *  Special : if decompression side sets a ring buffer, it must respect one of the following conditions :
 *  - Decompression buffer size is _at least_ LZ4_decoderRingBufferSize(maxBlockSize).
 *    maxBlockSize is the maximum size of any single block. It can have any value > 16 bytes.
 *    In which case, encoding and decoding buffers do not need to be synchronized.
 *    Actually, data can be produced by any source compliant with LZ4 format specification, and respecting maxBlockSize.
 *  - Synchronized mode :
 *    Decompression buffer size is _exactly_ the same as compression buffer size,
 *    and follows exactly same update rule (block boundaries at same positions),
 *    and decoding function is provided with exact decompressed size of each block, including the last one
 *    (decoding may write up to dst + dstCapacity, over data still referenced),
 *    _then_ decoding & encoding ring buffer can have any size, including small ones ( < 64 KB).
 *  - Decompression buffer is larger than encoding buffer, by a minimum of maxBlockSize + 64 bytes.
 *    In which case, encoding and decoding buffers do not need to be synchronized,
 *    and encoding ring buffer can have any size, including small ones ( < 64 KB).
 *
 *  Whenever these conditions are not possible,
 *  save the last 64KB of decoded data into a safe buffer where it can't be modified during decompression,
 *  then indicate where this data is saved using LZ4_setStreamDecode(), before decompressing next block.
*/
int
LZ4_decompress_safe_continue (LZ4_streamDecode_t* LZ4_streamDecode,
                        const(char)* src, char* dst,
                        int srcSize, int dstCapacity);


/*! LZ4_decompress_safe_usingDict() :
 *  Works the same as
 *  a combination of LZ4_setStreamDecode() followed by LZ4_decompress_safe_continue()
 *  However, it's stateless: it doesn't need any LZ4_streamDecode_t state.
 *  Dictionary is presumed stable : it must remain accessible and unmodified during decompression.
 *  Performance tip : Decompression speed can be substantially increased
 *                    when dst == dictStart + dictSize.
 */
int
LZ4_decompress_safe_usingDict(const(char)* src, char* dst,
                              int srcSize, int dstCapacity,
                              const(char)* dictStart, int dictSize);

/*! LZ4_decompress_safe_partial_usingDict() :
 *  Behaves the same as LZ4_decompress_safe_partial()
 *  with the added ability to specify a memory segment for past data.
 *  Performance tip : Decompression speed can be substantially increased
 *                    when dst == dictStart + dictSize.
 */
int
LZ4_decompress_safe_partial_usingDict(const(char)* src, char* dst,
                                      int compressedSize,
                                      int targetOutputSize, int maxOutputSize,
                                      const(char)* dictStart, int dictSize);

//end LZ4_H_2983827168210

/*^*************************************
 * !!!!!!   STATIC LINKING ONLY   !!!!!!
 ***************************************/

/*-****************************************************************************
 * Experimental section
 *
 * Symbols declared in this section must be considered unstable. Their
 * signatures or semantics may change, or they may be removed altogether in the
 * future. They are therefore only safe to depend on when the caller is
 * statically linked against the library.
 *
 * To protect against unsafe usage, not only are the declarations guarded,
 * the definitions are hidden by default
 * when building LZ4 as a shared/dynamic library.
 *
 * In order to access these declarations,
 * define LZ4_STATIC_LINKING_ONLY in your application
 * before including LZ4's headers.
 *
 * In order to make their implementations accessible dynamically, you must
 * define LZ4_PUBLISH_STATIC_FUNCTIONS when building the LZ4 library.
 ******************************************************************************/

/*! LZ4_ACCELERATION_DEFAULT, LZ4_ACCELERATION_MAX :
 *  "acceleration" values <= 0 are replaced by LZ4_ACCELERATION_DEFAULT.
 *  Values > LZ4_ACCELERATION_MAX are replaced by LZ4_ACCELERATION_MAX :
 *  higher values make no difference (fix #876).
 */

//if LZ4_STATIC_LINKING_ONLY
//ifn LZ4_STATIC_3504398509
enum LZ4_ACCELERATION_DEFAULT = 1;
enum LZ4_ACCELERATION_MAX = 65_537;


/*! LZ4_compress_fast_extState_fastReset() :
 *  A variant of LZ4_compress_fast_extState().
 *
 *  Using this variant avoids an expensive initialization step.
 *  It is only safe to call if the state buffer is known to be correctly initialized already
 *  (see above comment on LZ4_resetStream_fast() for a definition of "correctly initialized").
 *  From a high level, the difference is that
 *  this function initializes the provided state with a call to something like LZ4_resetStream_fast()
 *  while LZ4_compress_fast_extState() starts with a call to LZ4_initStream().
 */
int LZ4_compress_fast_extState_fastReset(
        void* state,
        const(char)* src,
        char* dst,
        int srcSize,
        int dstCapacity,
        int acceleration
    );
/*! LZ4_compress_destSize_extState() : introduced in v1.10.0
 *  Same as LZ4_compress_destSize(), but using an externally allocated state.
 *  Also: exposes @acceleration
 */
int LZ4_compress_destSize_extState(void* state, const(char)* src, char* dst, int* srcSizePtr, int targetDstSize, int acceleration);

/*! In-place compression and decompression
 *
 * It's possible to have input and output sharing the same buffer,
 * for highly constrained memory environments.
 * In both cases, it requires input to lay at the end of the buffer,
 * and decompression to start at beginning of the buffer.
 * Buffer size must feature some margin, hence be larger than final size.
 *
 * |<------------------------buffer--------------------------------->|
 *                             |<-----------compressed data--------->|
 * |<-----------decompressed size------------------>|
 *                                                  |<----margin---->|
 *
 * This technique is more useful for decompression,
 * since decompressed size is typically larger,
 * and margin is short.
 *
 * In-place decompression will work inside any buffer
 * which size is >= LZ4_DECOMPRESS_INPLACE_BUFFER_SIZE(decompressedSize).
 * This presumes that decompressedSize > compressedSize.
 * Otherwise, it means compression actually expanded data,
 * and it would be more efficient to store such data with a flag indicating it's not compressed.
 * This can happen when data is not compressible (already compressed, or encrypted).
 *
 * For in-place compression, margin is larger, as it must be able to cope with both
 * history preservation, requiring input data to remain unmodified up to LZ4_DISTANCE_MAX,
 * and data expansion, which can happen when input is not compressible.
 * As a consequence, buffer size requirements are much higher,
 * and memory savings offered by in-place compression are more limited.
 *
 * There are ways to limit this cost for compression :
 * - Reduce history size, by modifying LZ4_DISTANCE_MAX.
 *   Note that it is a compile-time constant, so all compressions will apply this limit.
 *   Lower values will reduce compression ratio, except when input_size < LZ4_DISTANCE_MAX,
 *   so it's a reasonable trick when inputs are known to be small.
 * - Require the compressor to deliver a "maximum compressed size".
 *   This is the `dstCapacity` parameter in `LZ4_compress*()`.
 *   When this size is < LZ4_COMPRESSBOUND(inputSize), then compression can fail,
 *   in which case, the return code will be 0 (zero).
 *   The caller must be ready for these cases to happen,
 *   and typically design a backup scheme to send data uncompressed.
 * The combination of both techniques can significantly reduce
 * the amount of margin required for in-place compression.
 *
 * In-place compression can work in any buffer
 * which size is >= (maxCompressedSize)
 * with maxCompressedSize == LZ4_COMPRESSBOUND(srcSize) for guaranteed compression success.
 * LZ4_COMPRESS_INPLACE_BUFFER_SIZE() depends on both maxCompressedSize and LZ4_DISTANCE_MAX,
 * so it's possible to reduce memory requirements by playing with them.
 */

enum int LZ4_DECOMPRESS_INPLACE_MARGIN(int compressedSize)= (compressedSize >> 8) + 32;

enum int LZ4_DECOMPRESS_INPLACE_BUFFER_SIZE(int decompressedSize)= decompressedSize +
        LZ4_DECOMPRESS_INPLACE_MARGIN!(decompressedSize);

enum LZ4_DISTANCE_MAX = 65_535;
enum LZ4_COMPRESS_INPLACE_MARGIN =
    LZ4_DISTANCE_MAX + 32; /* LZ4_DISTANCE_MAX can be safely replaced by srcSize when it's smaller */
enum int LZ4_COMPRESS_INPLACE_BUFFER_SIZE(int maxCompressedSize)=maxCompressedSize + LZ4_COMPRESS_INPLACE_MARGIN; /**< maxCompressedSize is generally LZ4_COMPRESSBOUND(inputSize), but can be set to any lower value, with the risk that compression can fail (return code 0(zero)) */
//end LZ4_STATIC_3504398509
//end LZ4_STATIC_LINKING_ONLY



//ifn LZ4_H_98237428734687

/*-************************************************************
 *  Private Definitions
 **************************************************************
 * Do not use these definitions directly.
 * They are only exposed to allow static allocation of `LZ4_stream_t` and `LZ4_streamDecode_t`.
 * Accessing members will expose user code to API and/or ABI break in future versions of the library.
 **************************************************************/
 enum LZ4_HASHLOG = LZ4_MEMORY_USAGE - 2;
enum LZ4_HASHTABLESIZE = 1 << LZ4_MEMORY_USAGE;
enum LZ4_HASH_SIZE_U32 = 1 << LZ4_HASHLOG; /* required as macro for static allocation */

alias LZ4_i8   = byte;
alias LZ4_byte = ubyte;
alias LZ4_u16  = ushort;
alias LZ4_u32  = uint;

/*! LZ4_stream_t :
 *  Never ever use below internal definitions directly !
 *  These definitions are not API/ABI safe, and may change in future versions.
 *  If you need static allocation, declare or allocate an LZ4_stream_t object.
**/
struct LZ4_stream_t_internal
{
    LZ4_u32[LZ4_HASH_SIZE_U32] hashTable;
    const(LZ4_byte)* dictionary;
    const(LZ4_stream_t_internal)* dictCtx;
    LZ4_u32 currentOffset;
    LZ4_u32 tableType;
    LZ4_u32 dictSize;
    /* Implicit padding to ensure structure is aligned */
}


enum LZ4_STREAM_MINSIZE = (1UL << 14) + 32;  /* static size, for inter-version compatibility */
union LZ4_stream_u
{
    char[LZ4_STREAM_MINSIZE] minStateSize;
    LZ4_stream_t_internal internal_donotuse;
} /* previously typedef'd to LZ4_stream_t */


/*! LZ4_initStream() : v1.9.0+
 *  An LZ4_stream_t structure must be initialized at least once.
 *  This is automatically done when invoking LZ4_createStream(),
 *  but it's not when the structure is simply declared on stack (for example).
 *
 *  Use LZ4_initStream() to properly initialize a newly declared LZ4_stream_t.
 *  It can also initialize any arbitrary buffer of sufficient size,
 *  and will @return a pointer of proper type upon initialization.
 *
 *  Note : initialization fails if size and alignment conditions are not respected.
 *         In which case, the function will @return NULL.
 *  Note2: An LZ4_stream_t structure guarantees correct alignment and size.
 *  Note3: Before v1.9.0, use LZ4_resetStream() instead
**/
LZ4_stream_t* LZ4_initStream (void* stateBuffer, size_t size);


/*! LZ4_streamDecode_t :
 *  Never ever use below internal definitions directly !
 *  These definitions are not API/ABI safe, and may change in future versions.
 *  If you need static allocation, declare or allocate an LZ4_streamDecode_t object.
**/
struct LZ4_streamDecode_t_internal
{
    const(LZ4_byte)* externalDict;
    const(LZ4_byte)* prefixEnd;
    size_t extDictSize;
    size_t prefixSize;
}

enum LZ4_STREAMDECODE_MINSIZE = 32;
union LZ4_streamDecode_u
{
    char[LZ4_STREAMDECODE_MINSIZE] minStateSize;
    LZ4_streamDecode_t_internal internal_donotuse;
}  /* previously typedef'd to LZ4_streamDecode_t */



/*-************************************
*  Obsolete Functions
**************************************/



/*! Removed in v1.11.0, deprecated since v1.7.x - v1.8.0 (liblz4 still exports them, for linked programs) :
 *  LZ4_compress*(), LZ4_uncompress*(), LZ4_create(), LZ4_sizeofStreamState(), LZ4_resetStreamState(),
 *  LZ4_slideInputBuffer(), LZ4_decompress_safe_withPrefix64k(), LZ4_decompress_fast_withPrefix64k() */

/*! Obsolete LZ4_decompress_fast variants (since v1.9.0) :
 *  These functions used to be faster than LZ4_decompress_safe(),
 *  but this is no longer the case. They are now slower.
 *  This is because LZ4_decompress_fast() doesn't know the input size,
 *  and therefore must progress more cautiously into the input buffer to not read beyond the end of block.
 *  On top of that `LZ4_decompress_fast()` is not protected vs malformed or malicious inputs, making it a security liability.
 *  As a consequence, LZ4_decompress_fast() is strongly discouraged, and deprecated.
 *
 *  The last remaining LZ4_decompress_fast() specificity is that
 *  it can decompress a block without knowing its compressed size.
 *  Such functionality can be achieved in a more secure manner
 *  by employing LZ4_decompress_safe_partial().
 *
 *  Parameters:
 *  originalSize : is the uncompressed size to regenerate.
 *                 `dst` must be already allocated, its size must be >= 'originalSize' bytes.
 * @return : number of bytes read from source buffer (== compressed size).
 *           The function expects to finish at block's end exactly.
 *           If the source stream is detected malformed, the function stops decoding and returns a negative result.
 *  note : LZ4_decompress_fast*() requires originalSize. Thanks to this information, it never writes past the output buffer.
 *         However, since it doesn't know its 'src' size, it may read an unknown amount of input, past input buffer bounds.
 *         Also, since match offsets are not validated, match reads from 'src' may underflow too.
 *         These issues never happen if input (compressed) data is correct.
 *         But they may happen if input data is invalid (error or intentional tampering).
 *         As a consequence, use these functions in trusted environments with trusted data **only**.
 */
 deprecated("This function is deprecated and unsafe. Consider using LZ4_decompress_safe_partial() instead")
int LZ4_decompress_fast(
    const(char)* src,
    char* dst,
    int originalSize
);
deprecated("This function is deprecated and unsafe. Consider migrating towards LZ4_decompress_safe_continue() instead.")
    int LZ4_decompress_fast_continue(
        LZ4_streamDecode_t* LZ4_streamDecode,
        const(char)* src,
        char* dst,
        int originalSize
    );

    deprecated("This function is deprecated and unsafe. Consider using LZ4_decompress_safe_partial_usingDict() instead.")
    int LZ4_decompress_fast_usingDict(
        const(char)* src,
        char* dst,
        int originalSize,
        const(char)* dictStart,
        int dictSize
    );
/*! LZ4_resetStream() : deprecated (v1.11.0)
 *  Same as LZ4_initStream(streamPtr, sizeof(LZ4_stream_t)) : prefer LZ4_initStream().
 *  To start a new stream with an initialized state, LZ4_resetStream_fast() is faster.
 */
deprecated("use LZ4_initStream(s, (*s).sizeof) instead") void LZ4_resetStream (LZ4_stream_t* streamPtr);


//end LZ4_H_98237428734687

}