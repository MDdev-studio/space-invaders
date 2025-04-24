asect 0x00
main: ext 
exception_handler1: ext
exception_handler2: ext
exception_handler3: ext
exception_handler4: ext
scan_enemy: ext
drawing: ext
some_int: ext

dc main, 0              # x0000
dc exception_handler1, 0 # x0004
dc exception_handler2, 0 # x0008
dc exception_handler3, 0 # x000C
dc exception_handler4, 0 # x0010
dc scan_enemy, 0        # x0014
dc drawing, 0           # x0018
dc some_int, 1          # x001C

align 0x0080

rsect main
# Запись
x_space: dc 0         # x80
y_space: dc 0         # x82
# Отрисовка
id_out_space: dc 0    # x84
x_out_space: dc 0     # x86
y_out_space: dc 0     # x88
command_space: dc 0   # x8a
# Просто пуля
bullet_id_space: dc 0 # x8c
bullet_x_space: dc 0  # x8e
bullet_y_space: dc 0  # x90
# Флаг коллизии
collision: dc 0       # x92
run: dc 0             # x94
speed: dc 0           # x96
vec: dc 0             # x98
gg: dc 0              # x9a

align 2

main>
    ldi r5, run
    ldi r6, 1
    st r5, r6

    ldi r6, 0
    st r5, r6

    ldi r5, bullet_id_space
    ldi r6, 10
    st r5, r6

    ldi r0, 56 #положение корабля. не трогаем
    ldi r1, 100 #расстояние. не трогаем

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
    ldi r6, 2
    st r5, r6 

    ei
    while
      ldi r1, gg
      ld r1, r1
      tst r1
    stays z
      wait
    wend

    halt

some_int>
ldi r1, vec
ldi r2, 2
st r1, r2
rti

scan_enemy>
push r2
push r5
push r6
push r3
push r4

ldi r5, command_space
ldi r6, 0  
st r5, r6        

ldi r5, x_space
ld r5, r3

sub r0, r3 #вычитаем из текущего положения нашего корабля положение монстра
      if 
        tst r3 #если разница отрицательная, тогда мы инвертируем число, чтобы провести сравнение по модулю. Нам необходимо проверить, является ли расстояние, полученное от монстром, меньше, чем то, что было
        is mi
        neg r3
        if 
          tst r1 #аналогично если у нас наименьшее расстояние имеет знак -
          is mi
          neg r1
          if 
            cmp r3, r1 #сравниваем их. если текущее расстояние до монстра меньше, перезаписываем r1
            is le
            neg r3
            move r3,r1
          fi
        else
          if #если одно число отрицательное, другое нет, тогда мы просто приводим лишь одно из них к положительному виду, чтобы нормально сравнить
            cmp r3, r1
            is le
            neg r3
            move  r3,r1
          fi
        fi
      else #если одно число отрицательное, другое нет, тогда мы просто приводим одно из них к положительному виду, чтобы нормально сравнить
        if 
          tst r1
          is mi
          neg r1
          if 
            cmp r3, r1
            is le
            move  r3,r1
          fi
        else
          if 
            cmp r3, r1
            is le
            move  r3,r1
          fi
        fi
      fi 
ld r5, r3
if 
  cmp r3, 61
  is eq
  ldi r5, vec
  ldi r4, 1
  st r5, r4
fi
if 
  cmp r3, 0
  is eq
  ldi r5, vec
  ldi r4, 1
  st r5, r4
fi
ldi r5, y_space
ld r5, r4
if
  cmp r4, 50
  is ge
  ldi r5, gg
  ldi r2, 1
  st r5, r2
fi
add r4, 2
ldi r5, bullet_y_space
ld r5, r2
sub r2, r4
if
    cmp r4, 3
    is le
    if
        cmp r4, -1
        is ge
    ldi r5, bullet_x_space
    ld r5, r2
    sub r2, r3
    if
        cmp r3, -1
        is ge
        if
            cmp r3, 3
            is le
            ldi r5, collision
            ldi r4, 1
            st r5, r4
            ldi r4, 0
            st r5, r4
            ldi r5, bullet_id_space
            ldi r4, 10
            st r5, r4
            fi
        fi
    fi
fi 
pop r4
pop r3
pop r6
pop r5
pop r2
rti

movement>
    push r6
        if
            cmp r1, 0        
            is eq            
            pop r6
            rts
        fi
        if
            cmp r1, 0        
            is gt            
            ldi r6, 1        
            sub r0, r6       
            move r6, r0      
        fi
        if
            cmp r1, 0        
            is lt            
            ldi r6, 1        
            add r6, r0       
        fi
        pop r6
    rts

drawing>
    di
    push r4
    push r3
    push r5
    push r6
    jsr movement
    ldi r5, id_out_space 
    ldi r6, 1
    st r5, r6

    ldi r5, x_out_space
    st r5, r0

    ldi r5, y_out_space
    ldi r6, 56 #можешь сделать это константой в схеме, я уберу тогда кусок 
    st r5, r6

    ldi r5, command_space
    ldi r6, 1  
    st r5, r6
    ldi r6, 0
    st r5, r6

    ldi r5, bullet_id_space
    ld r5, r4
    ldi r5, id_out_space
    st r5, r4
    if
        cmp r4, 9
        is ne
        if
            cmp r1, 1
            is le
            if
                cmp r1, -1
                is ge
                jsr ai_bullet_spawn
            fi
        fi
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
    ldi r6, 2
    st r5, r6
    ldi r6, 0
    st r5, r6
    ldi r5, vec
    ld r5, r4
    if 
      cmp r4, 1
      is eq
      ldi r1, 100
      ldi r4, 0
      st r5, r4
      #jsr scan_enemy
      int 1
    fi
    pop r6
    pop r5
    pop r3
    pop r4
    rti

ai_bullet_spawn>
    push r5
    push r6
    push r3

    ldi r5, bullet_id_space
    ldi r6, 9
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

ai_bullet_movement:
    push r5
    push r4
    push r6

    ldi r5, bullet_id_space
    ld r5, r6
    if
        cmp r6, 9
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
        ldi r6, 10          
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

exception_handler1>
ldi r1, gg
ldi r2, 1
ld r1, r2
halt

exception_handler2>
ldi r1, gg
ldi r2, 2
ld r1, r2
halt

exception_handler3>
ldi r1, gg
ldi r2, 3
ld r1, r2
halt

exception_handler4>
ldi r1, gg
ldi r2, 4
ld r1, r2
halt

end
