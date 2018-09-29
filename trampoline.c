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

#include <trampoline.h>

#if __has_include(<mach/mach.h>)

#include <mach/mach.h>

void* trampoline_allocate(size_t size) {
  vm_address_t addr = 0xB0000000; // PTHREAD_STACK_HINT
  int kr = vm_allocate(mach_task_self(), &addr, size, VM_MAKE_TAG(VM_MEMORY_STACK) | VM_FLAGS_ANYWHERE);
  if (kr != KERN_SUCCESS) return NULL;

  // Use one page for a guard page.
  vm_protect(mach_task_self(), addr, vm_page_size, FALSE, VM_PROT_NONE);

  return (void*)(addr + size);
}

void trampoline_deallocate(void* stack, size_t size) {
  vm_deallocate(mach_task_self(), (vm_address_t)(stack) - size, size);
}

/*
#elif __has_include(<alloca.h>)

void* trampoline_allocate(size_t size) {
  return alloca(size);
}

void trampoline_deallocate(void* stack, size_t size) {
  // Do nothing.
}
*/

#endif
