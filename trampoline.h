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

#pragma once

#ifndef TRAMPOLINE_AVAILABLE
#if ((defined(__arm__) || defined(__arm64__) || defined(__i386__) || defined(__x86_64__)) \
    && (__has_include(<mach/mach.h>)))
#define TRAMPOLINE_AVAILABLE 1
#else
#define TRAMPOLINE_AVAILABLE 0
#endif
#endif

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

void  trampoline_invoke(void* arg, void (*fp)(void*), void* stack, size_t size);
void* trampoline_allocate(size_t size);
void  trampoline_deallocate(void* stack, size_t size);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // defined(TRAMPOLINE_H_INCLUDED)
