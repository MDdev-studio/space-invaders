asect 0x00
main: ext 
exception_handler: ext

dc main, 0
dc exception_handler, 1
dc exception_handler, 2
dc exception_handler, 3
dc exception_handler, 4

align 0x0080

rsect main
# Recording
x_space: dc 0         # x80
y_space: dc 0         # x82
checker: dc 0         # x84
# Draw
id_out_space: dc 0    # x86
x_out_space: dc 0     # x88
y_out_space: dc 0     # x8a
command_space: dc 0   # x8c
# Ai_bullet
bullet_id_space: dc 0 # x8e
bullet_x_space: dc 0  # x90
bullet_y_space: dc 0  # x92
# Collision flag
collision: dc 0       # x94

#Technical moments
run: dc 0             # x96
speed: dc 0           # x98
vec: dc 0 #9a
gg: dc 0 #9c
score: dc 0 #9e
button: dc 0 #a0

#Player and his bullet
playbul_id_space: dc 0 #a2
playbul_x_space: dc 0 #a4
playbul_y_space: dc 0 #a6
playx_space: dc 0 #a8
playy_space: dc 0 #aa

#Enemies' shooting
rand: dc 0 #ac

#Win
win: dc 0 #ae

#HP
hp: dc 0 #b0

#Enemies' bullets
bull_1id: dc 0 #b2
bull_1x: dc 0 #b4
bull_1y: dc 0 #b6
bull_2id: dc 0 #b8
bull_2x: dc 0 #ba
bull_2y: dc 0 #bc

#Predicting
  nearestx: dc 0 #be
  nearesty: dc 0 #c0
  predictx: dc 0 #c2
  ismove: dc 0 #c4
  shot: dc 0 #c6

align 2


macro DELETE_BULL/1
  nop
  nop
  nop
  nop
  ldi r5, collision
  ld r5, r6

  if
    cmp r6, 0
  is ne
    if
      cmp r6, 1
    is eq
      ldi r3, hp
      ld r3, r6
      dec r6
      st r3, r6
      if 
        cmp r6, 0
      is le
        ldi r3, gg
        ldi r6, 1
        st r3, r6
      fi
    else
      if
        cmp r6, 2
      is eq
        ldi r3, score
        ld r3, r6
        inc r6
        st r3, r6
        if
          cmp r6, 15
        is ge
          ldi r3, win
          ldi r6, 1
          st r3, r6
        fi
      fi
    fi

    ldi r3, $0
    ldi r6, 9
    st r3, r6

    ldi r6, 0
    st r5, r6
  fi
mend


main>
  # Program initialization
  ldi r5, score
  ldi r6, 0
  st r5, r6
  ldi r5, ismove
  st r5, r6

  # The initial position of the bullets
  ldi r6, -1
  ldi r5, bullet_x_space
  st r5, r6
  ldi r5, bullet_y_space
  st r5, r6
  ldi r5, playbul_x_space
  st r5, r6
  ldi r5, playbul_y_space
  st r5, r6
  ldi r5, bull_1x
  st r5, r6
  ldi r5, bull_1y
  st r5, r6
  ldi r5, bull_2x
  st r5, r6
  ldi r5, bull_2y
  st r5, r6

  # Initial id of bullets (hiding)
  ldi r6, 9
  ldi r5, bullet_id_space
  st r5, r6
  ldi r5, playbul_id_space
  st r5, r6
  ldi r5, bull_1id
  st r5, r6
  ldi r5, bull_2id
  st r5, r6

  # The initial value of HP
  ldi r5, hp
  ldi r6, 3
  st r5, r6
    
  ldi r0, 56 #the position of the AI ship.
  ldi r1, 100 #Nearest distance

  ldi r5, vec #the initial vector of enemy movement.
  ldi r4, 0 #0 - right; 1 - left
  st r5, r4

  ldi r5, id_out_space 
  ldi r6, 1
  st r5, r6

  ldi r5, x_out_space
  st r5, r0

  ldi r5, y_out_space
  ldi r6, 56
  st r5, r6

  # Hardware Startup
  ldi r5, run
  ldi r6, 1
  st r5, r6

  ldi r6, 0
  st r5, r6

  ldi r5, checker
  check_loop:
  ld r5, r6
  if 
    cmp r6, 1
  is eq
    jsr scan_enemies
    ldi r5, checker
    ldi r6, 0
    st r5, r6
  else
    if  
      cmp r6, 2
    is eq
      jsr draw
      ldi r5, checker
      ldi r6, 0
      st r5, r6
    fi
  fi
  br check_loop

scan_enemies>
  ldi r5, command_space
  ldi r6, 0
  st r5, r6
 ldi r5, x_space
  ld r5, r3
  ldi r5, y_space
  ld r5, r4
  sub r0, r3
  ldi r7, 56
  sub r7, r4  

    #abs(r3)
  move r3, r7
  shra r7, 8
  shra r7, 7
  xor r7, r3, r5
  sub r5, r7
  move r7, r5

  # abs(r4)
  move r4, r6
  shra r6, 8
  shra r6, 7
  xor r6, r4, r7
  sub r7, r6
  add r5, r6, r7
  if
    cmp r7, r1
    is lt
    move r7, r1
    ldi r5, x_space
    ld r5, r3
    ldi r5, nearestx
    st r5, r3
    ldi r5, y_space
    ld r5, r3
    ldi r5, nearesty
    st r5, r3
    jsr predicting
  fi

  ldi r5, x_space
  ld r5, r3
  if 
    cmp r3, 59
  is eq
    ldi r5, vec
    ldi r4, 1
    st r5, r4
    ldi r5, predictx
    ldi r4, 0
    st r5, r4
  fi

  if 
    cmp r3, 1
  is eq
    ldi r5, vec
    ldi r4, 0
    st r5, r4
    ldi r5, predictx
    st r5, r4
  fi

  ldi r5, y_space
  ld r5, r4
  if
    cmp r4, 44
  is ge
    ldi r5, gg
    ldi r2, 1
    st r5, r2
  fi

  #Checking if the bullet of the first,second enemies exists
  ldi r5, bull_1id
  ld r5, r6
  if
    cmp r6, 9
  is eq
    ldi r5, rand
    ld r5, r6
    if
      cmp r6, 3
    is eq
      ldi r5, bull_1id
      ldi r6, 15
      st r5, r6
      ldi r5, x_space
      ld r5, r3
      add r3, 2
      ldi r5, bull_1x
      st r5, r3
      ldi r5, y_space
      ld r5, r4
      ldi r5, bull_1y
      st r5, r4
    fi
  fi

  #Spawn the bullets of the second enemy
  ldi r5, bull_2id
  ld r5, r6
  if
    cmp r6, 9
  is eq
    ldi r5, rand
    ld r5, r6
    if
      cmp r6, 2     
    is eq
      ldi r5, bull_2id
      ldi r6, 15
      st r5, r6
      ldi r5, x_space
      ld r5, r3
      add r3, 2
      ldi r5, bull_2x
      st r5, r3
      ldi r5, y_space
      ld r5, r4
      ldi r5, bull_2y
      st r5, r4
    fi
  fi

  rts

predicting>
  push r7 #t
  push r6  #x, where AI will need to move to
  push r5  
  push r2 #s

  # We always get the latest coordinates of the nearest enemy
  ldi r5, nearestx
  ld r5, r2
  ldi r5, nearesty
  ld r5, r5

  #Calculating the bullet flight time (56 - y_coord)
  ldi r7, 56
  sub r7, r5, r7

  #Determining the current direction of movement of the enemies
  ldi r5, vec
  ld r5, r5
  
  if
    cmp r5, 0 
    is eq # moving to the right
    #Calculating the position when moving to the right
    ldi r5, 64      #The right border
    sub r5, r2, r5   #Remaining distance to the wall
    ldi r6, 2
    sub r5, r6, r5    
    
    if
      cmp r7, r5
      is le #If the enemy doesn't have time to turn around
      add r2, r7, r6 #prediction with the current direction
    else
      #If the Enemy turns around
      sub r7, r5, r2 #remaining distance after reversal
      ldi r6, 61     #the starting point after the reversal (64-3)
      sub r6, r2, r6 # new predicted position
    fi
  else #Moving to the left
    #Similar logic for moving to the left
    if
      cmp r7, r2
      is le # If the enemy doesn't have time to turn around
      sub r2, r7, r6
    else
      sub r7, r2, r2
      ldi r6, 2      
      add r6, r2, r6
    fi
  fi

  #Saving the result
  ldi r5, predictx
  add r6, 2
  st r5, r6
  ldi r1, 100

  pop r2
  pop r5
  pop r6
  pop r7
  rts

movement>
  push r6
  push r5
  push r4
  
  

  
  #If already in motion (ismove = 1)
  ldi r5, predictx
  ld r5, r5             #Loading the target position
  
  if
    cmp r5, r0
    is lt               #If the target is on the left
    sub r0, 2           #Moving to the left
  fi
  
  if
    cmp r5, r0
    is gt               #If the target is on the right
    add r0, 2           #Moving to the right
  fi
  
  if
    cmp r5, r0
    is eq               #If you have reached the goal
    ldi r5, shot
    ldi r6, 1
    st r5, r6           #Setting the shooting flag
    
  fi

movement_end:
  pop r4
  pop r5
  pop r6
  rts

draw>
  jsr movement

  #Drawing AI
  ldi r5, id_out_space 
  ldi r6, 1
  st r5, r6

  ldi r5, x_out_space
  st r5, r0

  ldi r5, y_out_space
  ldi r6, 56 
  st r5, r6

  ldi r5, command_space
  ldi r6, 1
  st r5, r6
  ldi r6, 0
  st r5, r6

  #drawing an AI bullet
  ldi r5, bullet_id_space
  ld r5, r4
  ldi r5, id_out_space
  st r5, r4
  ldi r5, bullet_id_space
    ld r5, r4
        if
          cmp r4, 10
            is ne
                ldi r5, shot
                  ld r5, r6
                  if
                    cmp r6, 1
                    is eq
                    ldi r5, shot
                    ldi r6, 0
                    st r5, r6
                  fi
              jsr ai_bullet_spawn
            else
              jsr ai_bullet_movement
    fi
  
  ldi r3, bullet_x_space
  ld r3, r4
  ldi r5, x_out_space
  st r5, r4
  ldi r3, bullet_y_space
  ld r3, r4
  ldi r5, y_out_space
  st r5, r4
  ldi r5, command_space
  ldi r6, 1
  st r5, r6
  DELETE_BULL bullet_id_space
  ldi r5, command_space
  ldi r6, 0
  st r5, r6

  #Drawing the first enemy bullet
  ldi r5, bull_1id
  ld r5, r4
  if
    cmp r4, 15
  is eq
    jsr movebul
  fi

  ldi r5, id_out_space
  st r5, r4

  ldi r5, bull_1x
  ld r5, r4
  ldi r5, x_out_space
  st r5, r4
  ldi r3, bull_1y
  ld r3, r4
  ldi r5, y_out_space
  st r5, r4 
  ldi r5, command_space
  ldi r6, 1
  st r5, r6
  DELETE_BULL bull_1id
  ldi r5, command_space
  ldi r6, 0
  st r5, r6
  

  # Processing the enemy's second bullet
  ldi r5, bull_2id
  ld r5, r4
  if
    cmp r4, 15
  is eq
    jsr movebul2  
  fi

  #Drawing the second bullet
  ldi r5, id_out_space
  st r5, r4
  ldi r5, bull_2x
  ld r5, r4
  ldi r5, x_out_space
  st r5, r4
  ldi r3, bull_2y
  ld r3, r4
  ldi r5, y_out_space
  st r5, r4
  ldi r5, command_space
  ldi r6, 1
  st r5, r6
  DELETE_BULL bull_2id
  ldi r5, command_space
  ldi r6, 0
  st r5, r6

  

  #Drawing the player's bullet
  ldi r5, playbul_id_space
  ld r5, r4
  ldi r5, id_out_space
  st r5, r4

  if
    cmp r4, 10
  is ne
    ldi r5, button
    ld r5, r4
    if
      cmp r4, 1
    is eq
      jsr playbul_spawn
      ldi r4, 0
      st r5, r4
    fi
  else
    jsr playbul_movement
  fi

  ldi r3, playbul_x_space
  ld r3, r4
  ldi r5, x_out_space
  st r5, r4
  ldi r3, playbul_y_space
  ld r3, r4
  ldi r5, y_out_space
  st r5, r4
  ldi r5, command_space
  ldi r6, 1
  st r5, r6

  DELETE_BULL playbul_id_space

  ldi r5, command_space
  ldi r6, 2
  st r5, r6
  ldi r6, 0
  st r5, r6
  rts

ai_bullet_spawn:
  push r5
  push r6
  push r3

  ldi r5, bullet_id_space
  ldi r6, 10
  st r5, r6

  ldi r5, x_out_space
  ld r5, r3
  add r3, 2
  ldi r5, bullet_x_space
  st r5, r3

  ldi r3, 55
  ldi r5, bullet_y_space
  st r5, r3

  pop r3
  pop r6
  pop r5
  rts

playbul_spawn:
  push r5
  push r6
  push r3

  ldi r5, playbul_id_space
  ldi r6, 10
  st r5, r6

  ldi r5, playx_space
  ld r5, r3
  add r3, 2
  ldi r5, playbul_x_space
  st r5, r3

  ldi r5, playy_space
  ld r5, r3
  ldi r5, playbul_y_space
  st r5, r3

  pop r3
  pop r6
  pop r5
  rts


playbul_movement:
  push r5
  push r4
  push r6

  ldi r5, playbul_id_space
  ld r5, r6
  if
    cmp r6, 10
  is ne
    br playbul_movement_end
  fi

  ldi r5, playbul_y_space
  ld r5, r4
  sub r4, 2         
  if
    cmp r4, 0
  is lt
    ldi r5, playbul_id_space
    ldi r6, 9      
    st r5, r6
    br playbul_movement_end
  fi

  ldi r5, playbul_y_space
  st r5, r4


playbul_movement_end:
  pop r6
  pop r4
  pop r5
  rts


ai_bullet_movement:
  push r5
  push r4
  push r6

  ldi r5, bullet_id_space
  ld r5, r6
  if
    cmp r6, 10
  is ne
    br ai_bullet_movement_end
  fi

  ldi r5, bullet_y_space
  ld r5, r4
  sub r4, 2
  if
    cmp r4, 0
  is lt
    ldi r5, bullet_id_space
    ldi r6, 9
    st r5, r6
    br ai_bullet_movement_end
  fi

  ldi r5, bullet_y_space
  st r5, r4


ai_bullet_movement_end:
  pop r6
  pop r4
  pop r5
  rts


movebul:
  push r5
  push r4
  push r6

  ldi r5, bull_1id
  ld r5, r6
  if
    cmp r6, 15
  is ne
    br end_movebul
  fi

  ldi r5, bull_1y
  ld r5, r4
  add r4, 2
  if
    cmp r4, 58
  is ge
    ldi r5, bull_1id
    ldi r6, 9
    st r5, r6
    br end_movebul
  fi

  ldi r5, bull_1y
  st r5, r4


end_movebul:
  pop r6
  pop r4
  pop r5
  rts


movebul2:
  push r5
  push r4
  push r6

  ldi r5, bull_2id
  ld r5, r6
  if
    cmp r6, 15
  is ne
    br end_movebul2
  fi

  ldi r5, bull_2y
  ld r5, r4
  add r4, 2
  if
    cmp r4, 58
  is ge
    ldi r5,bull_2id
    ldi r6, 9
    st r5, r6
    br end_movebul2
  fi

  ldi r5, bull_2y
  st r5, r4


end_movebul2:
  pop r6
  pop r4
  pop r5
  rts


exception_handler>
  halt

end