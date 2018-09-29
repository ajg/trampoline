// Copyright (c) 2015 Joe Ranieri; 2018 Alvaro J. Genial
//
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
//   1. The origin of this software must not be misrepresented; you must not
//   claim that you wrote the original software. If you use this software
//   in a product, an acknowledgment in the product documentation would be
//   appreciated but is not required.
//
//   2. Altered source versions must be plainly marked as such, and must not be
//   misrepresented as being the original software.
//
//   3. This notice may not be removed or altered from any source
//   distribution.
//

#ifndef TRAMPOLINE_H_INCLUDED
#define TRAMPOLINE_H_INCLUDED

// #pragma once

#ifndef HAS_TRAMPOLINE_CALL
#if (defined(__arm__) || defined(__arm64__) || defined(__i386__) || defined(__x86_64__))
#define HAS_TRAMPOLINE_CALL 1
#else
#define HAS_TRAMPOLINE_CALL 0
#endif
#endif

#ifndef HAS_TRAMPOLINE_STACK
#if __has_include(<mach/mach.h>)
#define HAS_TRAMPOLINE_STACK 1
#else
#define HAS_TRAMPOLINE_STACK 0
#endif
#endif

#ifndef HAS_TRAMPOLINE
#if (HAS_TRAMPOLINE_CALL && HAS_TRAMPOLINE_STACK)
#define HAS_TRAMPOLINE 1
#else
#define HAS_TRAMPOLINE 0
#endif
#endif

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

#if HAS_TRAMPOLINE_CALL
void  trampoline_call(void* arg, void (*fp)(void*), void* stack, size_t size);
#endif
#if HAS_TRAMPOLINE_STACK
void* trampoline_allocate(size_t size);
void  trampoline_deallocate(void* stack, size_t size);
#endif

#ifdef __cplusplus
} // extern "C"
#endif

#endif // defined(TRAMPOLINE_H_INCLUDED)
