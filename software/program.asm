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


#Технические моменты
run: dc 0             # x96
speed: dc 0           # x98
vec: dc 0 #9a
gg: dc 0 #9c
score: dc 0 #9e
button: dc 0 #a0

#Игрок и его пуля
playbul_id_space: dc 0 #a2
playbul_x_space: dc 0 #a4
playbul_y_space: dc 0 #a6
playx_space: dc 0 #a8
playy_space: dc 0 #aa

#Стрельба врагов
rand: dc 0 #ac

#Победа
win: dc 0 #ae

#ХПШКИ
hp: dc 0 #b0

#Пули врагов
bull_1id: dc 0 #b2
bull_1x: dc 0 #b4
bull_1y: dc 0 #b6
bull_2id: dc 0 #b8
bull_2x: dc 0 #ba
bull_2y: dc 0 #bc



align 2

main>
    # Инициализация программы
    ldi r5, score
    ldi r6, 0
    st r5, r6

    ldi r5, bullet_x_space
    ldi r6, -1
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
    ldi r5, bullet_id_space
    ldi r6, 10
    st r5, r6
    ldi r5, playbul_id_space
    st r5, r6
    ldi r5, bull_1id
    st r5, r6
    ldi r5, bull_2id
    st r5, r6

    #Пропись хп
    ldi r5, hp
    ldi r6, 3
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

    # Запуск аппаратной части
    ldi r5, run
    ldi r6, 1
    st r5, r6

    ldi r6, 0
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
  cmp r3, 1
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

  #             ldi r5, playbul_id_space
  #             ldi r4, 10
  #             st r5, r4
  #             ldi r5, score
  #             ld r5, r4
  #             inc r4
  #             st r5, r4
  #             if
  #               cmp r4, 15
  #               is eq
  #               ldi r5, win
  #               ldi r4, 1
  #               st r5, r4
  #             fi
  #             fi
  #         fi
  #     fi
  # fi 


#Проверка, существует ли пуля первого,второго,третьего и т.д врагов (макс 6)
ldi r5, bull_1id
ld r5, r6
if
cmp r6, 10
is eq
  ldi r5, rand
  ld r5, r6
  if
  cmp r6, 3
    is eq
    ldi r5, bull_1id
    ldi r6, 9
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
# else тут будет огромный пласт с проверкой последующих ячеек пуль
fi
# Спавн пули второго врага
ldi r5, bull_2id
ld r5, r6
if
cmp r6, 10
is eq
  ldi r5, rand
  ld r5, r6
  if
  cmp r6, 2        # Отдельное условие для второго врага
    is eq
    ldi r5, bull_2id
    ldi r6, 9
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
pop r4
pop r3
pop r6
pop r5
pop r2
rts

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

macro DELETE_BULL/1
  ldi r5, collision
  ld r5, r6
  if
    cmp r6, 1
  is eq
    ldi r3, $0
    ldi r6, 10
    st r3, r6

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

    ldi r6, 0
    st r5, r6
  fi
mend

otrisovka>
    push r4
    push r3
    push r5
    push r6

    jsr movement

    # Отрисовка ИИ
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

    #отрисовка пули ИИ
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
    ldi r6, 0
    st r5, r6

    DELETE_BULL bullet_id_space

    #Отрисовка пуль врагов
    ldi r5, bull_1id
    ld r5, r4
     if
       cmp r4, 9
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
    ldi r6, 0
    st r5, r6

    DELETE_BULL bull_1id

# Обработка второй пули врага
ldi r5, bull_2id
ld r5, r4
if
  cmp r4, 9
  is eq
  jsr movebul2      # Новая подпрограмма для движения
fi

# Отрисовка второй пули
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
ldi r6, 0
st r5, r6

DELETE_BULL bull_2id

    #Отрисовка пули игрока
    ldi r5, playbul_id_space
    ld r5, r4
    ldi r5, id_out_space
    st r5, r4
    if
      cmp r4, 9
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

    save r5
    DELETE_BULL playbul_id_space
    restore

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
    fi
    #Возможно сломает всю логику ИИ, но попробовать надо
  # if 
  #   cmp r4, 0
  #   is eq
  #    ldi r1, 100
  #    ldi r4, 1
  #    st r5, r4
  #  fi
  #уберём если что
    pop r6
    pop r5
    pop r3
    pop r4
    rts

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

playbul_spawn>
    push r5
    push r6
    push r3

    ldi r5, playbul_id_space
    ldi r6, 9
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
        cmp r6, 9
        is ne
        br playbul_movement_end
    fi
    ldi r5, playbul_y_space
    ld r5, r4
    sub r4, 4               
    if
        cmp r4, 0
        is lt
        ldi r5, playbul_id_space
        ldi r6, 10          
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
        cmp r6, 9
        is ne
        br ai_bullet_movement_end
    fi
    ldi r5, bullet_y_space
    ld r5, r4
    sub r4, 4               
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


 movebul> 
    push r5
    push r4
    push r6

    ldi r5, bull_1id
    ld r5, r6
    if
        cmp r6, 9
        is ne
        br end_movebul
    fi
    ldi r5, bull_1y
    ld r5, r4
    add r4, 2               
    if
        cmp r4, 58
        is ge
        ldi r5,bull_1id
        ldi r6, 10          
        st r5, r6
        br ai_bullet_movement_end
    fi
    ldi r5, bull_1y
    st r5, r4
end_movebul:
    pop r6
    pop r4
    pop r5
    rts

movebul2> 
    push r5
    push r4
    push r6

    ldi r5, bull_2id
    ld r5, r6
    if
        cmp r6, 9
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
        ldi r6, 10          
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