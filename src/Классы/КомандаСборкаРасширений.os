///////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

// #Использовать logos
// #Использовать fs
// #Использовать v8runner

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     инициализируем пустую базу данных для выполнения необходимых тестов.
		|     указываем путь к исходниками с конфигурацией,
		|     указываем версию платформы, которую хотим использовать,
		|     и получаем по пути build\ib готовую базу для тестирования.";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ПараметрыСистемы.ВозможныеКоманды().СборкаРасширений, ТекстОписания);

	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "inputPath");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "extensionName");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры (необязательно) - Соответствие - дополнительные параметры
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	// КорневойПутьПроекта = ПараметрыСистемы.КорневойПутьПроекта;

	СобратьИзИсходниковРасширение(ОбщиеМетоды.ПолныйПуть(ПараметрыКоманды["inputPath"]), 
					ПараметрыКоманды["extensionName"],
					ПараметрыКоманды["--ibname"], ПараметрыКоманды["--db-user"], ПараметрыКоманды["--db-pwd"],
					ПараметрыКоманды["--v8version"]);

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду

Процедура СобратьИзИсходниковРасширение(Каталог, ИмяРасширения, Знач СтрокаПодключения="", Знач Пользователь="", Знач Пароль="", Знач ВерсияПлатформы="")

	УправлениеКонфигуратором = Новый УправлениеКонфигуратором();
		
	КаталогВременнойИБ = ВременныеФайлы.СоздатьКаталог();
	УправлениеКонфигуратором.КаталогСборки(КаталогВременнойИБ);
	
	КаталогРаспаковки = ВременныеФайлы.СоздатьКаталог();
	
	Если НЕ ПустаяСтрока(СтрокаПодключения) Тогда
		УправлениеКонфигуратором.УстановитьКонтекст(СтрокаПодключения, Пользователь, Пароль);
	КонецЕсли;
	
	Если Не ПустаяСтрока(ВерсияПлатформы) Тогда 
		УправлениеКонфигуратором.ИспользоватьВерсиюПлатформы(ВерсияПлатформы);
	КонецЕсли;
	
	ПараметрыЗапуска = УправлениеКонфигуратором.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить("/Visible");
	ПараметрыЗапуска.Добавить("/LoadConfigFromFiles """ + Каталог + """");
	ПараметрыЗапуска.Добавить("-Extension """ + ИмяРасширения + """");
	УправлениеКонфигуратором.ВыполнитьКоманду(ПараметрыЗапуска);

	ПоказатьСписокВсехРасширенийКонфигурации(УправлениеКонфигуратором);	
КонецПроцедуры

Процедура ПоказатьСписокВсехРасширенийКонфигурации(УправлениеКонфигуратором)
	ПараметрыЗапуска = УправлениеКонфигуратором.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить("/Visible");
	ПараметрыЗапуска.Добавить("/DumpDBCfgList");
	ПараметрыЗапуска.Добавить("-AllExtensions");
	УправлениеКонфигуратором.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация("Список расширений конфигурации:%2%1", УправлениеКонфигуратором.ВыводКоманды(), Символы.ПС);
КонецПроцедуры
