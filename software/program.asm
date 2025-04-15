asect 0x00
main: ext 
exception_handler: ext   

dc main, 0
dc exception_handler, 0
dc exception_handler, 0
dc exception_handler, 0
dc exception_handler, 0

align 0x0080

rsect main
# Запись
x_space: dc 0         # x80
y_space: dc 0         # x82
checker: dc 0         # x84
# Отрисовка
id_out_space: dc 0    # x86
x_out_space: dc 0     # x88
y_out_space: dc 0     # x8a
command_space: dc 0   # x8c
# Просто пуля
bullet_id_space: dc 0 # x8e
bullet_x_space: dc 0  # x90
bullet_y_space: dc 0  # x92
# Флаг коллизии
collision: dc 0       # x94
run: dc 0             # x96

align 2

main>
    ldi r5, run
    ldi r6, 1
    st r5, r6

    ldi r6, 0
    st r5, r6

    ldi r5, bullet_id_space
    ldi r6, 7
    st r5, r6

    ldi r0, 25 #положение корабля. не трогаем
    ldi r1, 100 #расстояние. не трогаем

    ldi r5, id_out_space 
    ldi r6, 1
    st r5, r6

    ldi r5, x_out_space
    st r5, r0

    ldi r5, y_out_space
    ldi r6, 29
    st r5, r6

    ldi r5, command_space 
    ldi r6, 1  
    st r5, r6 
    ldi r6, 2
    st r5, r6 



check_loop>
    ldi r5, checker
    ld r5, r6
    if 
        cmp r6, 1
        is eq
        jsr scan_enemies
        ldi r6, 0
        st r5, r6
    else
      if  
          cmp r6, 2
          is eq
          jsr otrisovka
          ldi r6, 0
          st r5, r6  
      fi
    fi
    br check_loop        

scan_enemies>
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
ldi r5, y_space
ld r5, r4
pop r4
pop r3
pop r6
pop r5
rts

# TODO: fix Unaligned PC exception (status 2)
movement>
    push r6
    if
        cmp r1, 0        
        is eq            
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
    if
        cmp r0, 0   
        is lt
        ldi r0, 0   
    fi
    if
        cmp r0, 29  
        is gt
        ldi r0, 29  
    fi
    rts

otrisovka>
    # TODO: uncomment it after fix
    # jsr movement
    ldi r5, id_out_space 
    ldi r6, 1
    st r5, r6

    ldi r5, x_out_space
    st r5, r0

    ldi r5, y_out_space
    ldi r6, 29 #можешь сделать это константой в схеме, я уберу тогда кусок 
    st r5, r6

    ldi r5, command_space
    ldi r6, 1  
    st r5, r6
    ldi r6, 0
    st r5, r6

    ldi r5, bullet_id_space
    ld r5, r4

    if
        cmp r4, 3
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
    ldi r5, command_space
    ldi r6, 1  
    st r5, r6
    ldi r6, 2
    st r5, r6
    ldi r6, 0
    st r5, r6
    rts

ai_bullet_spawn>
    push r5
    push r6
    push r3

    ldi r5, bullet_id_space
    ldi r6, 3
    st r5, r6

    ld r0, r3
    inc r3
    ldi r5, bullet_x_space
    st r5, r3

    ldi r3, 27
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
        cmp r6, 3
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
        ldi r6, 7          
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

exception_handler>
halt

end
