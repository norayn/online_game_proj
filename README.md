# online_game_proj

[ENG VERSION](https://github.com/norayn/online_game_proj/blob/master/README_ENG.md)

Период разработки: 04.2016 - 11.2017  
Цели проекта: изучение питона, клиент - серверного взаимодействия, архитектуры клинтских игр  
Клиент написан с применением фреймворка love2d 0.9.2  
Сервер: питон 2.7  

Старт сервера: server/run.py  
Старт клиента RUN_CLIENT.bat  
Старт редактора RUN_EDITOR.bat ( пути захардкожены, и без исправления не запустится )  

Управление:
*  Стрелки - движение
*  lctrl - слабый удар
*  lshift - сильный удар
*  Пробел - блок
*  Ввод - открыть чат / отправить
*  s - навыки
*  i - открыть инвентарь
*  p - открыть экипировку

Что было реализовано:
*  все расчеты на стороне сервера
*  2 вида передвижения хотьба и бег( с расходом стамины )
*  реалтаймовая боевая система( 2 удара, блок, толчек с разбега )
*  система статов с прокачкой
*  скелетная анимация с применением рантайма от spine
*  карта состоящая из набора спрайтов произвольного размера с данными о коллизиях и триггерами
*  самописный редактор карт
*  система загрузки и обработки разных объектов из конфига
*  гуи с отображением жизни стамины итп
*  система кастомизации внешнего вида персонажа пумем замены его отдельных спрайтов
*  система инвентаря
*  система пошагового боя
*  реализация ботов на стороне клиента
*  реализация ботов на стороне сервера
*  подсчет и отображения урона от ударов
*  чат


Скриншоты разных этапов разработки ( /progress_in_screenshots )  

![17_05_2017](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/17_05_2017.gif)
![12_08_2017](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/12_08_2017.gif)
![28_01_2017](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/28_01_2017.gif)
![04_04_2017](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/04_04_2017.gif)
![29_08_2017](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/29_08_2017.gif)
![31_07_2016](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/31_07_2016.jpg)
![1_08_2016_1](https://github.com/norayn/online_game_proj/blob/master/progress_in_screenshots/1_08_2016_1.jpg)
