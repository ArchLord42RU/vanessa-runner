///////////////////////////////////////////////////////////////////////////////////////////////////
//
// Подключение ИБ к хранилищу конфигурации 1С.
//
// TODO добавить фичи для проверки команды
// 
// Служебный модуль с набором методов работы с командами приложения
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////////////////////////////////////

#Использовать logos

Перем Лог;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ТекстОписания = 
		"     Копирование пользователей хранилища из другого хранилища.
		|     ";

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, 
		ТекстОписания);
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьПодключаемогоХранилища", 
		"Строка подключения к хранилищу
		|	(возможно указание как файлового пути, так и пути через http или tcp)");
Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьПодключаемогоХранилищаДляКопирования", 
		"Строка подключения к хранилищу для копирования пользователей
		|	(возможно указание как файлового пути, так и пути через http или tcp)");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-user", "Пользователь хранилища. 
		|	Обязательный параметр");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-pwd", "Пароль.
		|	Обязательный параметр");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-user-copy", "Пользователь хранилища. 
		|	Обязательный параметр");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "--storage-pwd-copy", "Пароль.
		|	Обязательный параметр");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   ДополнительныеПараметры - Соответствие - дополнительные параметры (необязательно)
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры = Неопределено) Экспорт

	Лог = ДополнительныеПараметры.Лог;

	ПутьКХранилищу          = ПараметрыКоманды["ПутьПодключаемогоХранилища"];
	ЛогинПользователя       = ПараметрыКоманды["--storage-user"];
	ПарольПользователя      = ПараметрыКоманды["--storage-pwd"];
	ПутьКХранилищуКопии     = ПараметрыКоманды["ПутьПодключаемогоХранилищаДляКопирования"];
	ЛогинПользователяКопии  = ПараметрыКоманды["--storage-user-copy"];
	ПарольПользователяКопии = ПараметрыКоманды["--storage-pwd-copy"];

	Ожидаем.Что(ПутьКХранилищу, " не задан путь к хранилищу").Заполнено();
	Ожидаем.Что(ЛогинПользователя, " не задан логин пользователя хранилища").Заполнено();
	Ожидаем.Что(ПарольПользователя, " не задан пароль пользователя хранилища").Заполнено();
	Ожидаем.Что(ПутьКХранилищуКопии, " не задан путь к хранилищу для копирования").Заполнено();
	Ожидаем.Что(ЛогинПользователяКопии, " не задан логин пользователя хранилища для копирования").Заполнено();
	Ожидаем.Что(ПарольПользователяКопии, " не задан пароль пользователя хранилища для копирования").Заполнено();
	
	ДанныеПодключения = ПараметрыКоманды["ДанныеПодключения"];
	СтрокаПодключения = ДанныеПодключения.СтрокаПодключения;
	Если Не ЗначениеЗаполнено(СтрокаПодключения) Тогда
		СтрокаПодключения = "/F";
	КонецЕсли;
	
	МенеджерКонфигуратора = Новый МенеджерКонфигуратора;

	МенеджерКонфигуратора.Инициализация(
		СтрокаПодключения,
		ДанныеПодключения.Пользователь,
		ДанныеПодключения.Пароль,
		ПараметрыКоманды["--v8version"],
		ПараметрыКоманды["--uccode"],
		ДанныеПодключения.КодЯзыка);

	Попытка
		МенеджерКонфигуратора.КопироватьПользователейИзХранилища(
			ПутьКХранилищу,
			ЛогинПользователя, 
			ПарольПользователя,
			ПутьКХранилищуКопии,
			ЛогинПользователяКопии,
			ПарольПользователяКопии);
	Исключение
		МенеджерКонфигуратора.Деструктор();
		ВызватьИсключение ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
	КонецПопытки;

	МенеджерКонфигуратора.Деструктор();

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;
КонецФункции // ВыполнитьКоманду
