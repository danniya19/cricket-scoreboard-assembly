INCLUDE Irvine32.inc

STD_OUTPUT_HANDLE EQU -11



.data
windowSize    COORD <65, 35>
windowRect    SMALL_RECT <0, 0, 64, 34>
stdOutHandle  HANDLE ?

runs        DWORD 0
wickets     DWORD 0
balls       DWORD 0
overs       DWORD 0
totalOvers  DWORD 0
extras      DWORD 0
target      DWORD 0

isSecondInn BYTE 0
legalBall   BYTE 1
freeHit     BYTE 0

teamAName      BYTE 21 DUP(0)
teamBName      BYTE 21 DUP(0)
batTeam        BYTE 21 DUP(0)
bowlTeam       BYTE 21 DUP(0)
tempTeam       BYTE 21 DUP(0)
tossWinnerName BYTE 21 DUP(0) 

; --- UI Strings ---
lineStr      BYTE "=================================================================",0
scoreTitle   BYTE "                         LIVE CRICKET SCOREBOARD                  ",0
msgTeamA     BYTE "Enter Team A Name: ",0
msgTeamB     BYTE "Enter Team B Name: ",0
msgMatch     BYTE "Match Type (1:T20 2:ODI 3:Custom): ",0
msgCustom    BYTE "Enter total overs: ",0
msgHeadsTail BYTE ", Select Heads(H) or Tails(T): ",0
msgTossWin   BYTE " won the toss! Bat(1) or Bowl(2): ",0

vsStr        BYTE "  VS  ",0
tossInfo     BYTE "TOSS WON BY: ",0
wonByStr     BYTE " won by ",0
runsSuffix   BYTE " Runs",0
wickSuffix   BYTE " Wickets",0

runsStr      BYTE "RUNS: ",0
wickStr      BYTE "  WICKETS: ",0
overStr      BYTE "OVERS: ",0
extraStr     BYTE "EXTRAS: ",0
targetStr    BYTE ">>> TARGET TO WIN: ",0
actionMsg    BYTE "1:Run 2:Wicket 3:WideBall 4:NoBall 5:OverThrow 7:End",0
choiceMsg    BYTE "Choice: ",0
runMsg       BYTE "Runs: ",0
runErrMsg    BYTE "Error: 0-6 only!",0
runErrMsg1   BYTE "Error: 0-4 only!",0
preRunMsg    BYTE "Before throw (0-3): ",0
preRunErrMsg BYTE "Error: 0-3 only!",0
boundaryMsg  BYTE "Boundary? (0:No, 4, 6): ",0
overMsg      BYTE "Overthrow runs (0-4): ",0
innEndMsg    BYTE "--- Innings Over! Press any key ---",0
freeHitMsg   BYTE "         *** FREE HIT! *** ",0

.code

gameLoop PROC
scoreLoop:
    call Clrscr
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET scoreTitle
    call WriteString
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    
    mov eax, white
    call SetTextColor
    mov edx, OFFSET teamAName
    call WriteString
    mov eax, gray
    call SetTextColor
    mov edx, OFFSET vsStr
    call WriteString
    mov eax, white
    call SetTextColor
    mov edx, OFFSET teamBName
    call WriteString
    call Crlf
    
    mov eax, cyan
    call SetTextColor
    mov edx, OFFSET tossInfo
    call WriteString
    mov edx, OFFSET tossWinnerName
    call WriteString
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf

    mov eax, lightGreen
    call SetTextColor
    mov edx, OFFSET batTeam
    call WriteString
    mov al, ' '
    call WriteChar
    mov edx, OFFSET runsStr
    call WriteString
    mov eax, runs
    call WriteDec
    mov al, '/'
    call WriteChar
    mov eax, wickets
    call WriteDec
    call Crlf

    mov eax, lightGray
    call SetTextColor
    mov edx, OFFSET overStr
    call WriteString
    mov eax, overs
    call WriteDec
    mov al, '.'
    call WriteChar
    mov eax, balls
    call WriteDec
    call Crlf

    cmp isSecondInn, 1
    jne skipTargetDisp
    mov eax, lightMagenta
    call SetTextColor
    mov edx, OFFSET targetStr
    call WriteString
    mov eax, target
    call WriteDec
    call Crlf
skipTargetDisp:

    call Crlf
    cmp freeHit, 1
    jne noFHDisp
    mov eax, white + (red * 16)
    call SetTextColor
    mov edx, OFFSET freeHitMsg
    call WriteString
    call Crlf
noFHDisp:

    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    mov eax, lightGray
    call SetTextColor
    mov edx, OFFSET actionMsg
    call WriteString
    call Crlf
    mov edx, OFFSET choiceMsg
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf

    cmp al, '1'
    je opRun
    cmp al, '2'
    je opWick
    cmp al, '3'
    je opWide
    cmp al, '4'
    je opNoBall
    cmp al, '5'
    je opOverthrow
    cmp al, '7'
    je manualEnd
    jmp scoreLoop

opRun:
validateRun:
    mov edx, OFFSET runMsg
    call WriteString
    call ReadChar
    call WriteChar
    sub al, '0'
    cmp al, 0
    jl runError
    cmp al, 6
    jg runError
    movzx eax, al
    add runs, eax
    mov legalBall, 1
    mov freeHit, 0
    call updateBall
    jmp scoreLoop
runError:
    call Crlf
    mov edx, OFFSET runErrMsg
    call WriteString
    call Crlf
    jmp validateRun

opWick:
    cmp freeHit, 1
    je skipWickCount
    inc wickets
skipWickCount:
    mov freeHit, 0
    mov legalBall, 1
    call updateBall
    jmp scoreLoop

opWide:
    inc runs
    inc extras
    mov legalBall, 0
    jmp scoreLoop

opNoBall:
    inc runs
    inc extras
    mov freeHit, 1
    mov legalBall, 0
validateNoBallRun:
    mov edx, OFFSET runMsg
    call WriteString
    call ReadChar
    call WriteChar
    sub al, '0'
    cmp al, 0
    jl noBallError
    cmp al, 6
    jg noBallError
    movzx eax, al
    add runs, eax
    jmp scoreLoop
noBallError:
    call Crlf
    mov edx, OFFSET runErrMsg
    call WriteString
    call Crlf
    jmp validateNoBallRun

opOverthrow:
validatePreRun:
    mov edx, OFFSET preRunMsg
    call WriteString
    call ReadChar
    call WriteChar
    sub al, '0'
    cmp al, 0
    jl preRunError
    cmp al, 3
    jg preRunError
    movzx ebx, al
    jmp validateBoundary
preRunError:
    call Crlf
    mov edx, OFFSET preRunErrMsg
    call WriteString
    call Crlf
    jmp validatePreRun

validateBoundary:
    call Crlf
    mov edx, OFFSET boundaryMsg
    call WriteString
    call ReadChar
    call WriteChar
    sub al, '0'
    cmp al, 0
    je noBoundary
    cmp al, 4
    je isBoundHit
    cmp al, 6
    je isBoundHit
    jmp validateBoundary

noBoundary:
validateOverRun:
    call Crlf
    mov edx, OFFSET overMsg
    call WriteString
    call ReadChar
    call WriteChar
    sub al, '0'
    cmp al, 0
    jl overRunError
    cmp al, 4
    jg overRunError
    movzx eax, al
    add ebx, eax
    add runs, ebx
    jmp finishOverthrow

overRunError:
    call Crlf
    mov edx, OFFSET runErrMsg1
    call WriteString
    jmp validateOverRun

isBoundHit:
    movzx eax, al
    add runs, eax
finishOverthrow:
    mov legalBall, 1
    mov freeHit, 0 
    call updateBall
    jmp scoreLoop

manualEnd:
    call checkInningsEnd
    ret
gameLoop ENDP

updateBall PROC
    cmp legalBall, 1
    jne endUB
    inc balls
    cmp balls, 6
    jne chkStats
    mov balls, 0
    inc overs
chkStats:
    cmp isSecondInn, 1
    jne normalStats
    mov eax, runs
    cmp eax, target
    jae callFinal
normalStats:
    cmp wickets, 10
    je callCheck
    mov eax, overs
    cmp eax, totalOvers
    je callCheck
    ret
callCheck:
    call checkInningsEnd
    ret
callFinal:
    call finalizeMatch
endUB:
    ret
updateBall ENDP

checkInningsEnd PROC
    cmp isSecondInn, 1
    je callFinalize
    mov eax, white
    call SetTextColor
    call Crlf
    mov edx, OFFSET innEndMsg
    call WriteString
    call WaitMsg
    mov eax, runs
    inc eax
    mov target, eax
    mov runs, 0
    mov wickets, 0
    mov balls, 0
    mov overs, 0
    mov extras, 0
    mov isSecondInn, 1
    mov esi, OFFSET batTeam
    mov edi, OFFSET tempTeam
    call CopyStr
    mov esi, OFFSET bowlTeam
    mov edi, OFFSET batTeam
    call CopyStr
    mov esi, OFFSET tempTeam
    mov edi, OFFSET bowlTeam
    call CopyStr
    call gameLoop
    ret
callFinalize:
    call finalizeMatch
    ret
checkInningsEnd ENDP

finalizeMatch PROC
    call Clrscr
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    mov eax, lightGreen
    call SetTextColor
    mov eax, runs
    cmp eax, target
    jae batWin
bowlWin:
    mov edx, OFFSET bowlTeam
    call WriteString
    mov edx, OFFSET wonByStr
    call WriteString
    mov eax, target
    dec eax
    sub eax, runs
    call WriteDec
    mov edx, OFFSET runsSuffix
    call WriteString
    jmp gameExit
batWin:
    mov edx, OFFSET batTeam
    call WriteString
    mov edx, OFFSET wonByStr
    call WriteString
    mov eax, 10
    sub eax, wickets
    call WriteDec
    mov edx, OFFSET wickSuffix
    call WriteString
gameExit:
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    call WaitMsg
    exit
finalizeMatch ENDP

CopyStr PROC
L1:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne L1
    ret
CopyStr ENDP
main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov stdOutHandle, eax
    INVOKE SetConsoleScreenBufferSize, stdOutHandle, windowSize
    INVOKE SetConsoleWindowInfo, stdOutHandle, TRUE, ADDR windowRect

    call Clrscr
    ; --- Start UI Header ---
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET scoreTitle
    call WriteString
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf

    mov eax, white
    call SetTextColor
    mov edx, OFFSET msgTeamA
    call WriteString
    mov edx, OFFSET teamAName
    mov ecx, 20
    call ReadString

    mov edx, OFFSET msgTeamB
    call WriteString
    mov edx, OFFSET teamBName
    mov ecx, 20
    call ReadString

    mov edx, OFFSET msgMatch
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf
    cmp al, '1'
    je setT20
    cmp al, '2'
    je setODI
    cmp al, '3'
    je setCustom
    mov totalOvers, 5
    jmp startToss

setT20:
    mov totalOvers, 20
    jmp startToss
setODI:
    mov totalOvers, 50
    jmp startToss
setCustom:
    mov edx, OFFSET msgCustom
    call WriteString
    call ReadDec
    mov totalOvers, eax

startToss:
    call Clrscr
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf
    mov eax, lightCyan
    call SetTextColor
    mov edx, OFFSET scoreTitle
    call WriteString
    call Crlf
    mov eax, yellow
    call SetTextColor
    mov edx, OFFSET lineStr
    call WriteString
    call Crlf

    mov eax, white
    call SetTextColor
    mov edx, OFFSET teamAName
    call WriteString
    mov edx, OFFSET msgHeadsTail
    call WriteString
    call ReadChar
    
    call Randomize
    mov eax, 2
    call RandomRange 
    
    cmp eax, 0
    jne teamBWinToss

    ; --- Team A Won Toss ---
    mov esi, OFFSET teamAName
    mov edi, OFFSET tossWinnerName
    call CopyStr
    call Crlf
    mov edx, OFFSET tossWinnerName
    call WriteString
    mov edx, OFFSET msgTossWin
    call WriteString
    call ReadChar
    
    cmp al, '1'          ; Choice 1: Bat
    je A_Bats_First
    jmp B_Bats_First     ; Choice 2: Bowl (Team B bats)

teamBWinToss:
    ; --- Team B Won Toss ---
    mov esi, OFFSET teamBName
    mov edi, OFFSET tossWinnerName
    call CopyStr
    call Crlf
    mov edx, OFFSET tossWinnerName
    call WriteString
    mov edx, OFFSET msgTossWin
    call WriteString
    call ReadChar

    cmp al, '1'          ; Choice 1: Bat
    je B_Bats_First
    jmp A_Bats_First     ; Choice 2: Bowl (Team A bats)

A_Bats_First:
    mov esi, OFFSET teamAName
    mov edi, OFFSET batTeam
    call CopyStr
    mov esi, OFFSET teamBName
    mov edi, OFFSET bowlTeam
    call CopyStr
    jmp beginMatch

B_Bats_First:
    mov esi, OFFSET teamBName
    mov edi, OFFSET batTeam
    call CopyStr
    mov esi, OFFSET teamAName
    mov edi, OFFSET bowlTeam
    call CopyStr

beginMatch:
    call gameLoop
    exit
main ENDP


END main