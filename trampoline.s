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

#if defined(__arm__)

//  void trampoline_invoke(void *arg, void (*fp)(void *), void *stack, size_t size);
//
//  |---------| <- r2 on entry
//  | prev lr |
//  |---------|
//  | prev r7 |
//  |---------| <- r7 will point here, giving us a frame pointer
//  | prev sp |
//  |---------|
//  |  size   |
//  |---------| <- sp will point here
//  |         |
//  |vvvvvvvvv|

.align 2
.globl _trampoline_invoke
_trampoline_invoke:
  # set up the saved stack frame
  stmfd r2!, { r7, lr }
  mov r7, r2
  # save off the size argument and the origianl stack pointer
  stmfd r2!, { r3, sp }
  # swap out the stack and invoke our target
  mov sp, r2
  # invoke our target function
  blx r1
  # store the fake stack off into r0
  mov r0, sp
  # read the size argument into r1 (not r3) and set sp to our original stack
  ldmfd r0!, { r1, sp }
  # restore the previous frame
  ldmfd r0!, { r7, lr }
  # and off we go with the arguments in place
  b _trampoline_deallocate

#elif defined(__arm64__)

# void trampoline_invoke(void *arg, void (*fp)(void *), void *stack, size_t size);
#
# |---------| <- x2 on entry
# |  size   |
# |---------|
# | prev sp |
# |---------|
# | prev lr |
# |---------|
# | prev fp |
# |---------| <- sp and fp will point here, giving us a frame pointer
# |         |
# |vvvvvvvvv|

.align 2
.globl _trampoline_invoke
_trampoline_invoke:
  # set up the saved stack frame
  stp fp, lr, [x2, #-32]!
  mov fp, x2
  # we need to save the original stack pointer to restore later and the size argument
  mov x17, sp
  stp x17, x3, [x2, #16]
  # swap out the stacks
  mov sp, x2
  # invoke our target function
  blr x1
  # restore the previous frame
  ldp fp, lr, [sp]
  # load the original stack pointer into x17 and the size argument back to x1
  ldp x17, x1, [sp, #16]
  # recalculate the original stack argument into x0
  add x0, sp, #32
  # swap the stacks back to the real one
  mov sp, x17
  # by this point, the stack argument is in x0 and the size argument in x1
  b _trampoline_deallocate

#elif defined(__i386__)

# void trampoline_invoke(void *arg, void (*fp)(void *), void *stack, size_t size);
#
# Here's how we'll set up the stack. Having a stack frame isn't required, but
# the space needs to be there for alignment and it's much nicer.
#
# |----------|
# | prev EIP |
# |----------|
# | prev EBP |
# |----------| <- EBP will point here, giving us a stack frame.
# | prev ESP |
# |----------|
# |    arg   |
# |----------| <- ESP points here and it must be be 16-byte aligned.
# |          |
# |vvvvvvvvvv|

.globl _trampoline_invoke
_trampoline_invoke:
  # Grab our new stack pointer and start setting things up...
  movl 12(%esp), %eax
  subl $16, %eax
  # Set up our stack frame entry.
  movl 0(%esp), %ecx
  movl %ecx, 12(%eax)
  movl %ebp, 8(%eax)
  leal 8(%eax), %ebp
  # Stash away the real stack pointer.
  movl %esp, 4(%eax)
  # Copy the function argument to the new stack.
  movl 4(%esp), %ecx
  movl %ecx, 0(%eax)
  # Swap our stack and the fake one, then call through to our target.
  xchg %eax, %esp
  call *8(%eax)
  # Reload the real stack pointer.
  movl 4(%esp), %esp
  # We must restore EBP before jumping out of here. Otherwise it's going to be
  # pointing at a spot on the stack that got freed.
  movl 0(%ebp), %ebp
  # Move our fake stack pointer to be arg1
  movl 12(%esp), %ecx
  movl %ecx, 4(%esp)
  # And move the stack size to be arg2
  movl 16(%esp), %ecx
  movl %ecx, 8(%esp)
  jmp _trampoline_deallocate

#elif defined(__x86_64__)

# void trampoline_invoke(void *arg, void (*fp)(void *), void *stack, size_t size);
# rdi = fp
# rsi = arg
# rdx = stack
# rcx = size
#
.globl _trampoline_invoke
_trampoline_invoke:
  # Store the original stack size and our custom stack size
  movq %rdx, -8(%rdx)
  movq %rcx, -16(%rdx)
  # Store the original stack address in order to revert to it later.
  movq %rsp, -24(%rdx)
  # Copy over the original return address so that stack traces look right.
  movq (%rsp), %rax
  movq %rax, -32(%rdx)
  # Start using our custom stack.
  movq %rdx, %rsp
  subq $32, %rsp
  # Happily invoke the target.
  call *%rsi
  # Grab the original stack and size so that we can pass them off to the trampoline_deallocate function.
  movq 24(%rsp), %rdi
  movq 16(%rsp), %rsi
  # Now restore the original stack pointer.
  movq 8(%rsp), %rsp
  # Now tail call out of here and free the custom stack.
  jmp _trampoline_deallocate

#else

// #error unsupported architecture

#endif
