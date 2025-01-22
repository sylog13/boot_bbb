# Build U-Boot

script변경..  
Docker container에서는 x-tools가 ~/home/${USER}/kernel에 설치된다.  
ch01에서 수정했던 내용인데,  
Docker container를 종료한 뒤에 x-tools가 사라지기 때문에  
Host환경과 공유하는 공간에 설치했다.  
