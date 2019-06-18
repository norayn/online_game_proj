# online_game_proj

Время разработки: 04.2016 - 11.2017
Старт сервера: server/run.py
Старт клиента RUN_CLIENT.bat
Старт редактора RUN_CLIENT.bat ( пути захардкожены, и без исправления не запустится )

Цели проекта: изучение питона, клиент - серверного взаимодействия, архитектуры клинтских игр
Клиент написан с применением фреймворка love2d 0.9.2
Сервер: питон 2.7

Управление:
	Стрелки - движение
	lctrl - слабый удар
	lshift - сильный удар
	Пробел - блок
	Ввод - открыть чат / отправить
	s - статус
	i - открыть инвентарь
	p - открыть экипировку

Что было реализовано:
	все расчеты на стороне сервера
	2 вида передвижения хотьба и бег( с расходом стамины )
	боевая система( 2 удара, блок, толчек с разбега )
	система статов с прокачкой
	скелетная анимация с применением рантайма от spine
	карта состоящая из набора спрайтов произвольного размера с данными о коллизиях и триггерами
	самописный редактор карт
	система загрузки и обработки разных объектов из конфига
	гуи с отображением жизни стамины итп
	система кастомизации внешнего вида персонажа пумем замены его отдельных спрайтов
	система инвентаря
	система пошагового боя
	реализация ботов на стороне клиента
	реализация ботов на стороне сервера
	подсчет и отображения урона от ударов
	чат