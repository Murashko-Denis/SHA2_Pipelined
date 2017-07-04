#Реализация алгоритма хеширования SHA-256 на FPGA#
  
**Среда:**  
Quartus II 15.0 Web Edition

#Общее описание алгоритма  
Хеш-функции семейства SHA-2 построены на основе структуры Меркла — Дамгарда.
Исходное сообщение после дополнения разбивается на блоки, каждый блок — на 16 слов. Алгоритм пропускает каждый блок сообщения через цикл с 64 итерациями (раундами). На каждой итерации 2 слова преобразуются, функцию преобразования задают остальные слова. Результаты обработки каждого блока складываются, сумма является значением хеш-функции. Тем не менее, инициализация внутреннего состояния производится результатом обработки предыдущего блока. Поэтому независимо обрабатывать блоки и складывать результаты нельзя [1].

**Схема одной итерации алгоритма SHA-2** 
![](https://upload.wikimedia.org/wikipedia/commons/7/7d/SHA-2.svg)  
Функция большинства (Ma блок) побитово работает со словами A, B и C. Для каждой битовой позиции она возвращает 0, если большинство входных битов в этой позиции — нули, иначе вернёт 1.

Блок Σ0 циклически сдвигает A на 2 бита, затем исходное слово A циклически сдвигается на 13 бит, и, аналогично, на 22 бита. Получившиеся три сдвинутые версии A побитово складываются по модулю 2 (обычный xor, (A ror 2) xor (A ror 13) xor (A ror 22)).

Ch реализует функцию выбора. На каждой битовой позиции проверяется бит из E, если он равен единице, то на выход идёт бит из F с этой позиции, иначе бит из G. Таким образом, биты из F и G перемешиваются, исходя из значения E.

Σ1 по структуре аналогичен Σ0, но работает со словом E, а соответствующие сдвиговые константы — 6, 11 и 25.

Красные блоки выполняют 32-битное сложение, формируя новые значения для выходных слов A и E. Значение Wt генерируется на основе входных данных (это происходит в том участке алгоритма, который получает и обрабатывает хэшируемые данные. Он вне нашего рассмотрения). Kt — своя константа для каждого раунда [2].


#Результаты синтеза
**Аппаратные затраты**  
![Аппаратные затраты](https://github.com/Murashko-Denis/SHA2_Pipelined/blob/master/res/Flow%20Summary.png)    
**Структура компонентов проекта и аппаратные затраты на каждый компонент**  
![Структура компонентов](https://github.com/Murashko-Denis/SHA2_Pipelined/blob/master/res/Components.png)   
**RTL Viewer**  
см. в res/RTL   
**Анализ быстродействия**  
![Анализ быстродействия](SHA2_Pipelined/res/Fmax.png)   
**При параметрах Clock:**    
![При параметрах Clock](https://github.com/Murashko-Denis/SHA2_Pipelined/blob/master/res/clock.png)   

#Моделирование  

Моделирование производилось в рамках пакета Modelsim, позволяющего использовать текстовое описание теста и осуществлять анализ правильности работы тестируемого модуля.
Для реализации тестирования разработан тест на языке Verilog (исходный код в папке testbench). 
В разработанном тесте на вход подаются данные на один заранее рассчитанный хеш (в отчете представлен для "abc").  
Хеш рассчитан на http://www.xorbin.com/tools/sha256-hash-calculator.

**Временная диаграмма**  
![Временная диаграмма](https://github.com/Murashko-Denis/SHA2_Pipelined/blob/master/testbench/vawe.bmp)     
**Лог файл находится в папке /res**

**Количество хешей в секунду**  
Количество тактов на расчет 1 хеша - 64 такта (сократить не получится так как вычисления последовательные).
Но конвейерная реализация при максимальной загрузке модуля позволяет получить 1 хеш за 1 такт.  
Количество хешей в секунду = (Тактовой частоте - 64 такта) = 24936 хешей/секунду.
(в данный момент нужно доделать тесты для конвейерной реализации, скорей всего она сразу не заработает)

#Список используемых источников  
1. https://ru.wikipedia.org/wiki/SHA-2 
2. https://habrahabr.ru/post/258181/#ref2 