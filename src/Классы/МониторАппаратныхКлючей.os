#Использовать logos
#Использовать 1commands
#Использовать strings

Перем Лог;

Перем ПутьКФайлуНастроек;
Перем ИсполнительКоманд;

// Получить путь к файлу настроек nethasp.ini.
//
//  Возвращаемое значение:
//   Строка - Путь к файлу настроек nethasp.ini.
//
Функция ПолучитьПутьКФайлуНастроек() Экспорт
    Возврат ПутьКФайлуНастроек;
КонецФункции

// Установить путь к файлу нстроек nethasp.ini.
//
// Параметры:
//   Путь - Строка - Путь к файлу настроек nethasp.ini.
//
Процедура УстановитьПутьКФайлуНастроек(Знач Путь) Экспорт
    ПутьКФайлуНастроек = Путь;
КонецПроцедуры

// Установить объект-исполнитель команд
//   
// Параметры:
//   НовыйИсполнитель - ИсполнительКоманд - новый объект-исполнитель команд
//
Процедура УстановитьИсполнительКоманд(Знач НовыйИсполнитель = Неопределено) Экспорт
	ИсполнительКоманд = НовыйИсполнитель;
КонецПроцедуры

// Выполняет команды через монитор аппаратных ключей
//
// Параметры:
//   ПараметрыКоманды - Массив - массив параметров команды 
//
//  Возвращаемое значение:
//   Строка - результат выполнения команды через монитор аппаратных ключей
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт

	ВыводКоманды = ИсполнительКоманд.ВыполнитьКоманду(ПараметрыКоманды);

	Возврат ВыводКоманды;
	
КонецФункции

// Возвращает таблицу менеджеров лицензий HASP
//
// Возвращаемое значение:
//   ТаблицаЗначений - список менеджеров лицензий
//    * Идентификатор - Строка - идентификатор
//    * Имя - Строка - имя
//    * Протокол - Строка - протокол
//    * Версия - Строка - версия
//    * ОперационнаяСистема - Строка - операционная система
//
Функция СписокМенеджеровЛицензий() Экспорт
	
	ТаблицаМенеджеровЛицензий = ПолучитьТаблицуМенеджеровЛицензий();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить(ОбернутьВКавычки("GET SERVERS"));

	СписокМенеджеровЛицензий = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокМенеджеровЛицензий);
	
	Для Каждого Элемент Из Данные Цикл
		
		ТекСтрока = ТаблицаМенеджеровЛицензий.Добавить();
		ТекСтрока.Идентификатор = Элемент["ID"];
		ТекСтрока.Имя = Элемент["NAME"];
		ТекСтрока.Протокол = Элемент["PROT"];
		ТекСтрока.Версия = Элемент["VER"];
		ТекСтрока.ОперационнаяСистема = Элемент["OS"];

		Лог.ПоляИз(Элемент).Отладка("Получено подключение к менеджеру лицензий");
		
	КонецЦикла;
	
	Возврат ТаблицаМенеджеровЛицензий;
	
КонецФункции

// Возвращает таблицу ключей менеджера лицензий HASP
//
// Параметры:
//   ИдентификаторМенеджера - Строка - идентификатор менеджера лицензий
//
// Возвращаемое значение:
//   ТаблицаЗначений - список ключей менеджера лицензий
//    * ИдентификаторМенеджера - Строка - идентификатор менеджера лицензий
//    * ПорядковыйНомер - Строка - имя ключа
//    * Тип - Строка - протокол
//    * Модель - Строка - версия менеджера лицензий
//    * ТекущееКоличествоПодключений - Число - операционная система менеджера лицензий
//
Функция СписокКлючейМенеджераЛицензий(Знач ИдентификаторМенеджера) Экспорт
	
	ТаблицаКлючей = ПолучитьТаблицуКлючей();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить(ОбернутьВКавычки(СтрШаблон("GET MODULES,ID=%1", ИдентификаторМенеджера)));

	СписокАппаратныхКлючей = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокАппаратныхКлючей);
	
	Для Каждого Элемент Из Данные Цикл
		
		ТекСтрока = ТаблицаКлючей.Добавить();
		ТекСтрока.ПорядковыйНомер = Элемент["MA"];
		ТекСтрока.Тип = Элемент["GENERATION"];
		ТекСтрока.Модель = Элемент["MAX"];
		ТекСтрока.ТекущееКоличествоПодключений = Число(Элемент["CURR"]);
		ТекСтрока.ИдентификаторМенеджера = ИдентификаторМенеджера;

		Лог.ПоляИз(Элемент).Отладка("Получен ключ");
		
	КонецЦикла;
	
	Возврат ТаблицаКлючей;
	
КонецФункции

// Возвращает таблицу подключений выбранного ключа HASP
//
// Параметры:
//   ПараметрыКлюча - Структура - параметры ключа 
//						  * ИдентификаторМенедежра - идентификатор менеджера лицензий
//						  * ПорядковыйНомер - номер ключа в менеджере лицензий 
//
// Возвращаемое значение:
//   ТаблицаЗначений - список подключений
//    * Номер - Строка - порядковый номер
//    * Протокол - Строка - протокол
//    * АдресХоста - Строка - адрес машины получившей лицензию
//    * ИмяХоста - Строка - имя машины получившей лицензию
//    * Таймаут - Строка - таймаут
//
Функция СписокПодключений(Знач ПараметрыКлюча, Знач Фильтр = Неопределено) Экспорт
	
	ТаблицаПодключений = ПолучитьТаблицуПодключений();
	
	Параметры = СтандартныеПараметрыЗапуска();
	Параметры.Добавить(ОбернутьВКавычки(
		СтрШаблон("GET LOGINS,ID=%1,MA=%2", ПараметрыКлюча.ИдентификаторМенеджера, ПараметрыКлюча.ПорядковыйНомер)
		));

	СписокПодключений = ВыполнитьКоманду(Параметры);	
	
	Данные = РазобратьПотокВывода(СписокПодключений);
	
	Для Каждого Элемент Из Данные Цикл
		
		ТекСтрока = ТаблицаПодключений.Добавить();
		ТекСтрока.Номер = Элемент["INDEX"];

		ПозицияОткр = Найти(Элемент["PROT"], "(");
		ПозицияЗакр = Найти(Элемент["PROT"], ")");
		// "UDP(127.0.0.1)"
		ТекСтрока.Протокол = Лев(Элемент["PROT"], ПозицияОткр - 1);
		ТекСтрока.АдресХоста = Сред(Элемент["PROT"], ПозицияОткр + 1, ПозицияЗакр - ПозицияОткр - 1);

		ТекСтрока.ИмяХоста = Элемент["NAME"];
		ТекСтрока.Таймаут = Элемент["TIMEOUT"];

		Лог.ПоляИз(Элемент).Отладка("Получено подключение к ключу");
		
	КонецЦикла;
	
	Возврат ТаблицаПодключений;
	
КонецФункции

Функция ПолучитьТаблицуМенеджеровЛицензий()
	
	ТаблицаМенеджеров = Новый ТаблицаЗначений;
	ТаблицаМенеджеров.Колонки.Добавить("Идентификатор");
	ТаблицаМенеджеров.Колонки.Добавить("Имя");
	ТаблицаМенеджеров.Колонки.Добавить("Протокол");
	ТаблицаМенеджеров.Колонки.Добавить("Версия");
	ТаблицаМенеджеров.Колонки.Добавить("ОперационнаяСистема");
	
	Возврат ТаблицаМенеджеров;

КонецФункции

Функция ПолучитьТаблицуКлючей()
	
	ТаблицаКлючей = Новый ТаблицаЗначений;
	ТаблицаКлючей.Колонки.Добавить("ИдентификаторМенеджера");
	ТаблицаКлючей.Колонки.Добавить("ПорядковыйНомер");
	ТаблицаКлючей.Колонки.Добавить("Тип");
	ТаблицаКлючей.Колонки.Добавить("Модель");
	ТаблицаКлючей.Колонки.Добавить("ТекущееКоличествоПодключений");
	
	Возврат ТаблицаКлючей;

КонецФункции

Функция ПолучитьТаблицуПодключений()
	
	ТаблицаПодключений = Новый ТаблицаЗначений;
	ТаблицаПодключений.Колонки.Добавить("Номер");
	ТаблицаПодключений.Колонки.Добавить("АдресХоста");
	ТаблицаПодключений.Колонки.Добавить("ИмяХоста");
	ТаблицаПодключений.Колонки.Добавить("Протокол");
	ТаблицаПодключений.Колонки.Добавить("Таймаут");
	
	Возврат ТаблицаПодключений;

КонецФункции

Функция СтандартныеПараметрыЗапуска()
	
	ПараметрыЗапуска = Новый Массив;

	ПараметрыЗапуска.Добавить(ОбернутьВКавычки("SET CONFIG,FILENAME=" + ОбернутьВКавычки(ПутьКФайлуНастроек)));
	ПараметрыЗапуска.Добавить(ОбернутьВКавычки("SCAN SERVERS"));
	
	Возврат ПараметрыЗапуска; 

КонецФункции

Функция ОбернутьВКавычки(Знач Строка)
	Если Лев(Строка, 1) = """" И Прав(Строка, 1) = """" Тогда
		Возврат Строка;
	Иначе
		Возврат """" + Строка + """";
	КонецЕсли;
КонецФункции

Функция РазобратьПотокВывода(Знач Поток)
	
	ТД = Новый ТекстовыйДокумент;
	ТД.УстановитьТекст(Поток);
	
	СписокОбъектов = Новый Массив;
	
	Для Сч = 1 По ТД.КоличествоСтрок() Цикл

		Текст = ТД.ПолучитьСтроку(Сч);
		Если ПустаяСтрока(Текст) 
			ИЛИ СтрНайти(Текст, "OK") > 0
			ИЛИ СтрНайти(Текст, "ERROR") > 0 
			ИЛИ СтрНайти(Текст, "EMPTY") > 0 Тогда
			Продолжить; // пропуск строки
		КонецЕсли;
				
		ТекущийОбъект = Новый Соответствие;
		МассивПараметров = СтрРазделить(Текст, ",");

		Для каждого Параметр Из МассивПараметров Цикл
					
			СтрокаРазбораИмя      = "";
			СтрокаРазбораЗначение = "";
	
			Если РазобратьНаКлючИЗначение(Параметр, СтрокаРазбораИмя, СтрокаРазбораЗначение) Тогда
				ТекущийОбъект[СтрокаРазбораИмя] = СтрокаРазбораЗначение;
			КонецЕсли;				

		КонецЦикла;
		
		СписокОбъектов.Добавить(ТекущийОбъект);

	КонецЦикла;
		
	Возврат СписокОбъектов;
	
КонецФункции

Функция РазобратьНаКлючИЗначение(Знач СтрокаРазбора, Ключ, Значение)

	ПозицияРазделителя = Найти(СтрокаРазбора, "=");
	Если ПозицияРазделителя = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Ключ     = СокрЛП(Лев(СтрокаРазбора, ПозицияРазделителя - 1));
	Значение = УбратьКавычки(СокрЛП(Сред(СтрокаРазбора, ПозицияРазделителя + 1)));
	
	Возврат Истина;
	
КонецФункции

Функция УбратьКавычки(Знач СтрокаСКавычками)
	
	СтрокаБезКавычек = СтрокаСКавычками;

	Если СтрНачинаетсяС(СтрокаСКавычками, """") Тогда
		СтрокаБезКавычек = Сред(СтрокаБезКавычек, 2);
	КонецЕсли;

	Если СтрЗаканчиваетсяНа(СтрокаСКавычками, """") Тогда
		СтрокаБезКавычек = Лев(СтрокаБезКавычек, СтрДлина(СтрокаБезКавычек) - 1);
	КонецЕсли;

	СтрокаБезКавычек = СтрЗаменить(СтрокаБезКавычек, """""", """");

	Возврат СтрокаБезКавычек;

КонецФункции

Процедура ПриСозданииОбъекта()

	Лог = Логирование.ПолучитьЛог("oscript.lib.v8haspmonitor");
	Лог = Логирование.ПолучитьЛог("oscript.lib.commands");
	Лог.УстановитьУровень(УровниЛога.Отладка);

	ПутьКФайлуНастроек = ".\examples\nethasp.ini";
	
	ИсполнительКоманд = Новый ИсполнительКоманд; 

КонецПроцедуры