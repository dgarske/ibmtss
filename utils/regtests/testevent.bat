REM #############################################################################
REM #									        #
REM #			TPM2 regression test					#
REM #			     Written by Ken Goldman				#
REM #		       IBM Thomas J. Watson Research Center			#
REM #										#
REM # (c) Copyright IBM Corporation 2020 - 2022                                 #
REM # 										#
REM # All rights reserved.							#
REM # 										#
REM # Redistribution and use in source and binary forms, with or without	#
REM # modification, are permitted provided that the following conditions are	#
REM # met:									#
REM # 										#
REM # Redistributions of source code must retain the above copyright notice,	#
REM # this list of conditions and the following disclaimer.			#
REM # 										#
REM # Redistributions in binary form must reproduce the above copyright		#
REM # notice, this list of conditions and the following disclaimer in the	#
REM # documentation and/or other materials provided with the distribution.	#
REM # 										#
REM # Neither the names of the IBM Corporation nor the names of its		#
REM # contributors may be used to endorse or promote products derived from	#
REM # this software without specific prior written permission.			#
REM # 										#
REM # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS	#
REM # "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT		#
REM # LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR	#
REM # A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT	#
REM # HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,	#
REM # SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT		#
REM # LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,	#
REM # DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY	#
REM # THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT	#
REM # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE	#
REM # OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.	#
REM #										#
REM #############################################################################

setlocal enableDelayedExpansion

echo ""
echo "UEFI"
echo ""

for %%F in ("dell1" "hp1" "ideapad1" "deb1" "deb2" "p511" "sm1" "sm2" "ubuntu1" "ubuntu2"  "ubuntu3" "amd635") do (

    echo "Power cycle to reset IMA PCR"
    %TPM_EXE_PATH%powerup > run.out
    IF !ERRORLEVEL! NEQ 0 (
        exit /B 1
    )

    echo "Startup"
    %TPM_EXE_PATH%startup > run.out
    IF !ERRORLEVEL! NEQ 0 (
       exit /B 1
    )

    echo "UEFI %%F"
    %TPM_EXE_PATH%eventextend -checkhash -v -tpm -sim -checkpcr -if %%F.log > run.out
    IF !ERRORLEVEL! NEQ 0 (
        exit /B 1
    )
)

echo ""
echo "IMA"
echo ""

for %%T in ( "1" "2") do (
     for %%H in (%ITERATE_ALGS%) do (

	echo "Power cycle to reset IMA PCR"
	%TPM_EXE_PATH%powerup > run.out
    	IF !ERRORLEVEL! NEQ 0 (
            exit /B 1
	)

	echo "Startup"
	%TPM_EXE_PATH%startup > run.out
    	IF !ERRORLEVEL! NEQ 0 (
            exit /B 1
	)

 	echo "IMA %%H Test Log type %%T simulate"
	%TPM_EXE_PATH%imaextend -le -if imatest.log -sim -halg %%H -ty %%T  -checkhash -of tmpsim.bin > run.out
    	IF !ERRORLEVEL! NEQ 0 (
            exit /B 1
	)

	echo "IMA %%H Test Log type %%T extend"
	%TPM_EXE_PATH%imaextend -le -if imatest.log -tpm -halg %%H -ty %%T  -checkhash -v > run.out
    	IF !ERRORLEVEL! NEQ 0 (
            exit /B 1
	)

	echo "PCR read %%H"
	%TPM_EXE_PATH%pcrread -ha 10 -halg %%H -of tmppcr.bin > run.out
    	IF !ERRORLEVEL! NEQ 0 (
            exit /B 1
	)

	echo "Verify PCR vs sim"
	diff tmppcr.bin tmpsim.bin > run.out
   	IF !ERRORLEVEL! NEQ 0 (
            exit /B 1
	)
    )
)

REM # cleanup

rm -f tmppcr.bin
rm -f tmpsim.bin
