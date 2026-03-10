workspace {
    name "Управление проектами"

    model {

        //Роли
        guest = person "Гость" "Незарегистрированный пользователь"
        tracker = person "Руководитель" "Роль, которая следит за задачами проекта, может свободно их передвигать, создавать, отменять. Так же управляет релизами"
        worker = person "Исполнитель" "Роль, которая отвечает за свои задачи. Так же может создавать задачи" 
        administrator = person "Администратор" "Следит за работой площадки"

        //Внешние сервисы
        notificationProvider = softwareSystem "Система уведомлений" "Внешний сервис для отправки уведомлений об создании задачи или изменении её статуса "
        codeSpace = softwareSystem "Хранилище кода" "Внещний сервис для хранения кода и связи задачи с ним"

        tasksSystem = softwareSystem "Система управления проектам" {
            frontApp = container "UI" "Сервис, отвечающий за принятие запросов"
            apiApplication = container "Api" "Сервис, перенаправляющая запросы"

            projectDb = container "DB" "Хранит информацию о проектах, задачах и пользователях" "PostgreSQL"

            userService = container "UserService" "Сервис, отвечающий за регистрацию клиентов и получения информации по клиенту"

            projectService = container "ProjectService" "Сервис, отвечающий за создание, удаление и изменение проектов"
            taskService = container "TaskService" "Сервис, отвечающий за создание, удаление и изменения задач"
        }

        guest -> tasksSystem "Регистрация пользователя"
        tracker -> tasksSystem "Управление задачами"
        worker -> tasksSystem "Выполнение задач"
        administrator -> tasksSystem "Администрирование"

        tasksSystem -> notificationProvider "Отправка уведомлений" "HTTPS/REST"
        tasksSystem -> codeSpace "Синхронизация с репозиторием" "HTTPS/REST"

        guest -> frontApp "Открывает форму регистрации" "HTTPS"
        tracker -> frontApp "Работает с интерфейсом управления" "HTTPS"
        worker -> frontApp "Просматривает и обновляет задачи" "HTTPS"
        administrator -> frontApp "Управляет настройками системы" "HTTPS"

        frontApp -> apiApplication "Отправляет пользовательские запросы" "HTTPS/JSON"

        apiApplication -> userService "Взаимодействие с сервисом пользователей" "REST/JSON"
        apiApplication -> projectService "Изменения проектов" "REST/JSON"
        apiApplication -> taskService "Изменения задач" "REST/JSON"

        userService -> projectDb "Данные пользователей" "JDBC"
        projectService -> projectDb "Данные проектов" "JDBC"
        taskService -> projectDb "Данные задач" "JDBC"

        taskService -> codeSpace "Связь с репозиторием" "HTTPS/REST"
        
        taskService -> notificationProvider "Отправка данных для отправки уведомлений" "HTTPS/REST"
    }

    views {
        systemContext tasksSystem {
            title "System Context - Управление проектами"
            description "Система в контексте пользователей и внешних систем"
            include *
            autoLayout
        }

        container tasksSystem {
            title "Container Diagram - сервис управления проектами"
            description "Внутренние взаимодействие сервиса"
            include *
            autoLayout
        }

        dynamic tasksSystem {
            title "Dynamic Diagram - Создание задачи в проекте"
            description "Последовательность взаимодействия при создании новой задачи"
            
            tracker -> frontApp "Заполняет форму создания задачи"
            
            frontApp -> apiApplication "Запрос на создание задачи в проекте"
            
            apiApplication -> projectService "Проверка: существует ли проект"
            projectService -> projectDb "Поиск проекта по идентификатору"
            projectDb -> projectService "Данные проекта найдены"
            projectService -> apiApplication "Проект существует, можно создавать задачу"
            
            apiApplication -> taskService "Создание новой задачи" 
            taskService -> projectDb "Сохранение данных задачи"
            projectDb -> taskService "Задача успешно сохранена"
            

            taskService -> notificationProvider "Отправка email-уведомления"
            
            taskService -> codeSpace "Привязка задачи к репозиторию кода"
            
            taskService -> apiApplication "Задача создана, возвращаю данные" 
            apiApplication -> frontApp "Ответ с данными созданной задачи" 
            frontApp -> tracker "Отображение созданной задачи в интерфейсе"

            autolayout lr
        }

        themes default 
    }
}