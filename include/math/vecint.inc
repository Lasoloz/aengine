;
; Copyright (c) 2016 László Heim
;
; Header file with integer based vector functions
; - Create 2D vector
; - Delete 2D vector
; - Move 2D vector
; - 2D vector arithmetics
;
; Dependencies:
;   third-party/util.inc  third-party/io.inc
;

%ifndef __VECINT_INC__
%define __VECINT_INC__

;;;
extern create_vec2int32
; Create 2D vector in the heap
; An integer vector is defined by an array of 64 bits (2*32)
;
; Returned value:
; eax - Pointer to an array of dwords sized 2 (and set to 0 values)
;     - 0 value in case of failure


;;;
extern delete_vec2int32
; Deallocate a 2D vector if it was created in heap
;
; Parameters:
; eax - Pointer to the array of vector
; Returned value:
; eax - Modified to 0 (NULL pointer)


;;;
extern print_vec2int32
; Prints out the value of the vector
;
; Parameter:
; eax - Pointer to the array of vector


;;;
extern add_vec2int32
; Add a 2D vector to the another
; Result is stored in the first vector (SO first vector is MODIFIED!)
;
; Parameters:
; eax - Pointer to the first vector array
; edx - Pointer to the second vector array
; Result:
; eax - Pointer to the (first) vector array


;;;
extern add_x_vec2int32
; Add value to the x component of a vector
; Result is stored int the vector (SO vector is MODIFIED!)
;
; Parameters:
; eax - Pointer to the vector array
; edx - Value to be added to the x component
; Result:
; eax - Pointer to the (SAME) vector array


;;;
extern add_y_vec2int32
; Add value to the y component of a vector
; Result is stored int the vector (SO vector is MODIFIED!)
;
; Parameters:
; eax - Pointer to the vector array
; edx - Value to be added to the y component
; Result:
; eax - Pointer to the (SAME) vector array


;;;
extern neg_vec2int32
; Negate a vector
; This modifies the value of the vector!
;
; Parameter:
; eax - Pointer to the vector array
; Result:
; eax - Pointer to the (same) vector array


;;;
extern sub_vec2int32
; Subtract a vector from the another
; Result is stored in the first vector (so it's MODIFIED!)
;
; Parameters:
; eax - Pointer to the first vector array
; edx - Pointer to the second vector array
; Result:
; eax - Pointer to the (first) vector array


;;;
extern mul_s_vec2int32
; Multiply a vector with a scalar value
; Result is stored in the vector (so it's MODIFIED!)
;
; Parameters:
; eax - Pointer to the vector's array
; edx - The scalar value
; Result:
; eax - Pointer to the (same) vector array


;;;
extern div_s_vec2int32
; Divide a vector with a scalar value
; Result is stored in the vector (so it's MODIFIED!)
;
; Parameters:
; eax - Pointer to the vector's array
; edx - The scalar value
; Result:
; eax - Pointer to the (same) vector array


;;;
extern cpy_vec2int32
; Copy the values of a 2D vector to the other vector
; The target vector must be allocated!
;
; Parameters:
; eax - Pointer to the first vector
; edx - Pointer to the second vector
; Result:
; eax - Value of edx copied to eax


;;;
extern c_v2int32_to_ps
; Convert an integer 2D vector to an SSE floating point vector
;
; Parameters:
; eax - Pointer to the vector
; Returned:
; xmm0 - Value converted to floating point vector


extern c_ps_to_v2int32
; Convert a floating point vector to an integer type 2D vector
;
; Parameters:
; xmm0 - Floating point vector
; eax - Pointer to the allocated array of 2D vector
; Result:
; eax - Pointer to the modified vector (copied converted values)

%endif
