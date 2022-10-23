# Индивидуальное домашнее задание №1
#### Студент: Нечесов Андрей Львович
#### Группа: БПИ217
#### Вариант: 15
## Содержание
- [Структура решения](#Запуск-программы-и-первое-тестирование)


## Введение

## Уточнения по условию

## Формат работы программы

## Критерии на 4 балла
### Написано решение на C
[Исходный монолитный код](https://github.com/Bopobywek/csa-ihw1/blob/main/src/program.c)
### Комментарии к программе на ассемблере и компиляция программы

Трансформируем код написанный на языке C в язык ассемблера:
```console
gcc -masm=intel -fno-asynchronous-unwind-tables -fno-jump-tables -fno-stack-protector -fno-exceptions program.c -S -o program.s
```

Код на языке ассемблера прокомментирован: [program.s](https://github.com/Bopobywek/csa-ihw1/blob/main/src/program.s)

Откомпилируем полученную программу без использования отладочных и оптимизируюзих опций:
```console
gcc program.s -o program
```

### Из ассемблерной программы убраны лишние макросы
Часть работы уже была проделана опциями при трансформации. Теперь руками уберем из ассемблерной программы метаинформацию:
```assembly
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:

```
И следующие команды:  
`endbr64` обеспечивает дополнительную безопасность, но в нашем идеально мире ИДЗ нет злых хакеров, поэтому удаляем команду.  
`nop` используется для выравнивания, так как подчистили всю метаинформацию, можно тоже удалить.

Итоговая модифицированная программа: reduced.s
### Модифицированная ассемблерная программа отдельно откомпилирована
```console
gcc reduced.s -o reduced
```
### Тесты
Был составлен небольшой набор тестов для проверки граничных случаев:
0. Весь входной массив состоит из нулей
1. Во входном массиве нет нулей
2. Во входном массиве есть числа как меньше нуля, так и больше
3. Входной массив размера 1, причем элемент массива не равен 0
4. Входной массив размера 1, причем этот единственный элемент является нулем
5. Случайный массив

Все они находятся в папке tests и расположены в следующем порядке:
<Номер теста из списка выше> -- сам тест
<Номер теста из списка выше>.a -- ответ на тест

Теперь воспользуемся скриптом и запустим тесты для двух программ:
```console
./test.py -t tests/ src/program
./test.py -t tests/ src/reduced
```

Получаем одинаковые результаты:

![alt text](https://github.com/Bopobywek/csa-ihw1/blob/main/screenshots/small_tests_result1.jpg)

Запустим ещё 100 случайных тестов для наших программ при помощи скрипта:  
<p align="center">
  <img src="https://github.com/Bopobywek/csa-ihw1/blob/main/screenshots/large_test_result1.jpg">
</p>

Перевели вывод по тестированию в соответствующий текстовый файл для каждой из программы. Затем сравнили их содержимое и посчитали количество правильных ответов. Результат отличный: обе программы прошли все 100 тестов

## Критерии на 5 баллов
Программа на C изначально была написана так, что в ней использовались и локальные переменные, и вызовы функций (с передачей параметров). Код на языке ассемблера также содержатся требуемые комментарии на оценку 5

## Критерии на 6 баллов
Исходный код оптимизированной программы: [optimized.s](https://github.com/Bopobywek/csa-ihw1/blob/main/src/program.s) (прокомментирован)  

### Модификация программы
Рефакторинг программы на ассемблере за счет максимального использования регистров процессор производился заменой загрузки переменных в стек на callee-saved регистры (rbx, r12, r13, r14, r15).

Причем эксперементально было выяснено, что соблюдение соглашения callee-saved в написанных самостоятельно функциях с какого-то момента приводило лишь к увеличению времени работы, поэтому некоторые функции по-прежнему используют стек.

Таким образом, по результатам работы все функции, кроме `main` и `mesaureTime` используют для хранения локальных переменных регистры.  
Так как изначально в программу встроен замер времени, получилось провести замер:

<p align="center">
  <img src="https://github.com/Bopobywek/csa-ihw1/blob/main/screenshots/time_optimized.jpg">
</p>
А вот, что получалось при соблюдении соглашения по callee-saved регистрам
<p align="center">
  <img src="https://github.com/Bopobywek/csa-ihw1/blob/main/screenshots/time_optimized_callee.jpg">
</p>

Ожидаемый эффект достигнут :)

### Тесты
Для проверки корректности запустим 100 случайных тестов при помощи скрипта:
```console
#!/bin/bash

gcc optimized.s -o optimized
../test.py --n 100 ./optimized > ../logs/log_optimized
grep -c ../logs/log_optimized -e "\bCorrect"

```

Все тесты успешно пройдены:
<p align="center">
  <img src="https://github.com/Bopobywek/csa-ihw1/blob/main/screenshots/optimized_test.jpg">
</p>

Сам лог: [log_optimized](https://github.com/Bopobywek/csa-ihw1/blob/main/logs/https://github.com/Bopobywek/csa-ihw1/blob/main/logs/log_optimized)
