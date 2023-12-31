USE [master]
GO
/****** Object:  Database [flower-store]    Script Date: 11/1/2023 6:40:04 PM ******/
CREATE DATABASE [flower-store]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'flower-store', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\flower-store.mdf' , SIZE = 12288KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'flower-store_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\flower-store_log.ldf' , SIZE = 5696KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [flower-store] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [flower-store].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [flower-store] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [flower-store] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [flower-store] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [flower-store] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [flower-store] SET ARITHABORT OFF 
GO
ALTER DATABASE [flower-store] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [flower-store] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [flower-store] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [flower-store] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [flower-store] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [flower-store] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [flower-store] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [flower-store] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [flower-store] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [flower-store] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [flower-store] SET  ENABLE_BROKER 
GO
ALTER DATABASE [flower-store] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [flower-store] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [flower-store] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [flower-store] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [flower-store] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [flower-store] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [flower-store] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [flower-store] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [flower-store] SET  MULTI_USER 
GO
ALTER DATABASE [flower-store] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [flower-store] SET DB_CHAINING OFF 
GO
ALTER DATABASE [flower-store] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [flower-store] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [flower-store]
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Receiver') DROP SERVICE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender') DROP SERVICE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Receiver') DROP QUEUE [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender') DROP QUEUE [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b') DROP CONTRACT [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ID') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ID/old') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/FromUserID') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ToUserID') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Content') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Content/old') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/CreatedDate') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Send') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Send/old') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/EndMessage') DROP MESSAGE TYPE [dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_00f34838-2410-4c6b-acb4-7df0ea9ee86b_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Receiver') DROP SERVICE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender') DROP SERVICE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Receiver') DROP QUEUE [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender') DROP QUEUE [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd') DROP CONTRACT [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ID') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ID/old') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/FromUserID') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ToUserID') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Content') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Content/old') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/CreatedDate') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Send') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Send/old') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/EndMessage') DROP MESSAGE TYPE [dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_0162322c-cb51-4226-889d-7b85f81a42cd_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Receiver') DROP SERVICE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender') DROP SERVICE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Receiver') DROP QUEUE [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender') DROP QUEUE [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107') DROP CONTRACT [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ID') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ID/old') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/FromUserID') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ToUserID') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Content') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Content/old') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/CreatedDate') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Send') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Send/old') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/EndMessage') DROP MESSAGE TYPE [dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_01e9f15d-2af4-42c4-87b7-84a0cd850107_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Receiver') DROP SERVICE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender') DROP SERVICE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Receiver') DROP QUEUE [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender') DROP QUEUE [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221') DROP CONTRACT [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ID') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ID/old') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/FromUserID') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ToUserID') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Content') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Content/old') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/CreatedDate') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Send') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Send/old') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/EndMessage') DROP MESSAGE TYPE [dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_0647a137-5bbb-49ba-ae51-db8f0527a221_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Receiver') DROP SERVICE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender') DROP SERVICE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Receiver') DROP QUEUE [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender') DROP QUEUE [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79') DROP CONTRACT [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ID') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ID/old') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/FromUserID') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ToUserID') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Content') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Content/old') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/CreatedDate') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Send') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Send/old') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/EndMessage') DROP MESSAGE TYPE [dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_121215e1-0b6a-41bd-a4ab-787b320a9b79_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Receiver') DROP SERVICE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender') DROP SERVICE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Receiver') DROP QUEUE [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender') DROP QUEUE [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f') DROP CONTRACT [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ID') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ID/old') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/FromUserID') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ToUserID') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Content') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Content/old') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/CreatedDate') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Send') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Send/old') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/EndMessage') DROP MESSAGE TYPE [dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_131f666b-f6f4-4c71-aa8b-f88a06813a5f_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Receiver') DROP SERVICE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender') DROP SERVICE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Receiver') DROP QUEUE [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender') DROP QUEUE [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97') DROP CONTRACT [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ID') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ID/old') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/FromUserID') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ToUserID') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Content') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Content/old') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/CreatedDate') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Send') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Send/old') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/EndMessage') DROP MESSAGE TYPE [dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_160a5a33-1cf9-47ae-88bf-7f65ab63fc97_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Receiver') DROP SERVICE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender') DROP SERVICE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Receiver') DROP QUEUE [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender') DROP QUEUE [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92') DROP CONTRACT [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ID') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ID/old') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/FromUserID') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ToUserID') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Content') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Content/old') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/CreatedDate') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Send') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Send/old') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/EndMessage') DROP MESSAGE TYPE [dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_16ab18e3-9ffe-4e47-b73f-591c18fa4d92_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Receiver') DROP SERVICE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender') DROP SERVICE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Receiver') DROP QUEUE [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender') DROP QUEUE [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15') DROP CONTRACT [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ID') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ID/old') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/FromUserID') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ToUserID') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Content') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Content/old') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/CreatedDate') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Send') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Send/old') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/EndMessage') DROP MESSAGE TYPE [dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_1b564357-a4f0-4d30-93f8-484e9789bb15_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Receiver') DROP SERVICE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender') DROP SERVICE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Receiver') DROP QUEUE [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender') DROP QUEUE [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553') DROP CONTRACT [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ID') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ID/old') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/FromUserID') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ToUserID') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Content') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Content/old') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/CreatedDate') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Send') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Send/old') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/EndMessage') DROP MESSAGE TYPE [dbo_Message_225f55d6-0481-48df-a889-5596d53e2553/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_225f55d6-0481-48df-a889-5596d53e2553_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Receiver') DROP SERVICE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender') DROP SERVICE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Receiver') DROP QUEUE [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender') DROP QUEUE [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4') DROP CONTRACT [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ID') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ID/old') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/FromUserID') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ToUserID') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Content') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Content/old') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/CreatedDate') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Send') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Send/old') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/EndMessage') DROP MESSAGE TYPE [dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_25ebdb2b-2e1e-4154-a8dc-83e1f1363dc4_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Receiver') DROP SERVICE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender') DROP SERVICE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Receiver') DROP QUEUE [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender') DROP QUEUE [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10') DROP CONTRACT [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ID') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ID/old') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/FromUserID') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ToUserID') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Content') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Content/old') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/CreatedDate') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Send') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Send/old') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/EndMessage') DROP MESSAGE TYPE [dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_26a622e1-e1c3-4444-a569-9c8afb530a10_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Receiver') DROP SERVICE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender') DROP SERVICE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Receiver') DROP QUEUE [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender') DROP QUEUE [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad') DROP CONTRACT [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ID') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ID/old') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/FromUserID') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ToUserID') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Content') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Content/old') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/CreatedDate') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Send') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Send/old') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/EndMessage') DROP MESSAGE TYPE [dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_36b244d0-a768-4524-a907-fa9ab36e84ad_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Receiver') DROP SERVICE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender') DROP SERVICE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Receiver') DROP QUEUE [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender') DROP QUEUE [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27') DROP CONTRACT [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ID') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ID/old') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/FromUserID') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ToUserID') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Content') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Content/old') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/CreatedDate') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Send') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Send/old') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/EndMessage') DROP MESSAGE TYPE [dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_3804c5e4-3cc3-4718-82cd-d56e6390cd27_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Receiver') DROP SERVICE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender') DROP SERVICE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Receiver') DROP QUEUE [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender') DROP QUEUE [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f') DROP CONTRACT [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ID') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ID/old') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/FromUserID') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ToUserID') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Content') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Content/old') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/CreatedDate') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Send') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Send/old') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/EndMessage') DROP MESSAGE TYPE [dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_3edfd559-0471-4ecc-ba9b-be6f14cc6d6f_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Receiver') DROP SERVICE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender') DROP SERVICE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Receiver') DROP QUEUE [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender') DROP QUEUE [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981') DROP CONTRACT [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ID') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ID/old') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/FromUserID') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ToUserID') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Content') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Content/old') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/CreatedDate') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Send') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Send/old') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/EndMessage') DROP MESSAGE TYPE [dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_4539119d-2fdb-48a9-98ce-1ae1b5185981_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Receiver') DROP SERVICE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender') DROP SERVICE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Receiver') DROP QUEUE [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender') DROP QUEUE [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa') DROP CONTRACT [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ID') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ID/old') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/FromUserID') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ToUserID') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Content') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Content/old') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/CreatedDate') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Send') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Send/old') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/EndMessage') DROP MESSAGE TYPE [dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_46254719-27c5-4fb1-9bda-b95a3559aaaa_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Receiver') DROP SERVICE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender') DROP SERVICE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Receiver') DROP QUEUE [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender') DROP QUEUE [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267') DROP CONTRACT [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ID') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ID/old') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/FromUserID') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ToUserID') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Content') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Content/old') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/CreatedDate') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Send') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Send/old') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/EndMessage') DROP MESSAGE TYPE [dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_4934d725-83f2-48d2-a26a-aa90052f4267_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Receiver') DROP SERVICE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender') DROP SERVICE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Receiver') DROP QUEUE [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender') DROP QUEUE [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d') DROP CONTRACT [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ID') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ID/old') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/FromUserID') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ToUserID') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Content') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Content/old') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/CreatedDate') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Send') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Send/old') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/EndMessage') DROP MESSAGE TYPE [dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_557e94a7-29de-4653-80fc-19b54ce3683d_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Receiver') DROP SERVICE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender') DROP SERVICE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Receiver') DROP QUEUE [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender') DROP QUEUE [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17') DROP CONTRACT [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ID') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ID/old') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/FromUserID') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ToUserID') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Content') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Content/old') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/CreatedDate') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Send') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Send/old') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/EndMessage') DROP MESSAGE TYPE [dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_62df4f18-8dae-4f31-a8cd-e5eb9fbd4b17_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Receiver') DROP SERVICE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender') DROP SERVICE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Receiver') DROP QUEUE [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender') DROP QUEUE [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349') DROP CONTRACT [dbo_Message_63309513-0970-4b06-b1a0-36227352f349];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ID') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ID/old') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/FromUserID') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ToUserID') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Content') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Content/old') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/CreatedDate') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Send') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Send/old') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349/EndMessage') DROP MESSAGE TYPE [dbo_Message_63309513-0970-4b06-b1a0-36227352f349/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_63309513-0970-4b06-b1a0-36227352f349_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_63309513-0970-4b06-b1a0-36227352f349_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Receiver') DROP SERVICE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender') DROP SERVICE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Receiver') DROP QUEUE [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender') DROP QUEUE [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac') DROP CONTRACT [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ID') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ID/old') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/FromUserID') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ToUserID') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Content') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Content/old') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/CreatedDate') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Send') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Send/old') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/EndMessage') DROP MESSAGE TYPE [dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_64f9ec8c-a1cb-4575-a03e-c62327e0b3ac_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Receiver') DROP SERVICE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender') DROP SERVICE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Receiver') DROP QUEUE [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender') DROP QUEUE [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5') DROP CONTRACT [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ID') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ID/old') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/FromUserID') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ToUserID') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Content') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Content/old') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/CreatedDate') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Send') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Send/old') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/EndMessage') DROP MESSAGE TYPE [dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_690510ce-24dd-4524-9f75-5c4379583fa5_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Receiver') DROP SERVICE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender') DROP SERVICE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Receiver') DROP QUEUE [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender') DROP QUEUE [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d') DROP CONTRACT [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ID') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ID/old') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/FromUserID') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ToUserID') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Content') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Content/old') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/CreatedDate') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Send') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Send/old') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/EndMessage') DROP MESSAGE TYPE [dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_69a445bb-1d5a-4f90-b797-6a78ffbe833d_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Receiver') DROP SERVICE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender') DROP SERVICE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Receiver') DROP QUEUE [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender') DROP QUEUE [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793') DROP CONTRACT [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ID') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ID/old') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/FromUserID') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ToUserID') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Content') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Content/old') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/CreatedDate') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Send') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Send/old') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/EndMessage') DROP MESSAGE TYPE [dbo_Message_70600439-717f-4f49-9e35-6cd03684f793/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_70600439-717f-4f49-9e35-6cd03684f793_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Receiver') DROP SERVICE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender') DROP SERVICE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Receiver') DROP QUEUE [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender') DROP QUEUE [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13') DROP CONTRACT [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ID') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ID/old') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/FromUserID') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ToUserID') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Content') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Content/old') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/CreatedDate') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Send') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Send/old') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/EndMessage') DROP MESSAGE TYPE [dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_73be3d39-c839-4791-8ea6-eddc20532c13_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Receiver') DROP SERVICE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender') DROP SERVICE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Receiver') DROP QUEUE [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender') DROP QUEUE [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19') DROP CONTRACT [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ID') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ID/old') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/FromUserID') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ToUserID') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Content') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Content/old') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/CreatedDate') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Send') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Send/old') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/EndMessage') DROP MESSAGE TYPE [dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_8511e6c2-96a2-467d-aa3a-da4d8a623d19_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Receiver') DROP SERVICE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender') DROP SERVICE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Receiver') DROP QUEUE [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender') DROP QUEUE [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87') DROP CONTRACT [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ID') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ID/old') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/FromUserID') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ToUserID') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Content') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Content/old') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/CreatedDate') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Send') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Send/old') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/EndMessage') DROP MESSAGE TYPE [dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_8c0483ea-f68c-46e7-9cf2-3bc07ce5be87_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Receiver') DROP SERVICE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender') DROP SERVICE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Receiver') DROP QUEUE [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender') DROP QUEUE [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc') DROP CONTRACT [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ID') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ID/old') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/FromUserID') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ToUserID') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Content') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Content/old') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/CreatedDate') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Send') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Send/old') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/EndMessage') DROP MESSAGE TYPE [dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_9b6ed371-f7da-49e5-9997-44cd7a7e00cc_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Receiver') DROP SERVICE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender') DROP SERVICE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Receiver') DROP QUEUE [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender') DROP QUEUE [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e') DROP CONTRACT [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ID') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ID/old') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/FromUserID') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ToUserID') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Content') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Content/old') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/CreatedDate') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Send') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Send/old') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/EndMessage') DROP MESSAGE TYPE [dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_a71139c4-fe1b-455a-994e-930ed6a9251e_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Receiver') DROP SERVICE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender') DROP SERVICE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Receiver') DROP QUEUE [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender') DROP QUEUE [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6') DROP CONTRACT [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ID') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ID/old') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/FromUserID') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ToUserID') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Content') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Content/old') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/CreatedDate') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Send') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Send/old') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/EndMessage') DROP MESSAGE TYPE [dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_a8523236-10c7-4d68-825b-3d90c89c70f6_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Receiver') DROP SERVICE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender') DROP SERVICE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Receiver') DROP QUEUE [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender') DROP QUEUE [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7') DROP CONTRACT [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ID') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ID/old') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/FromUserID') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ToUserID') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Content') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Content/old') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/CreatedDate') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Send') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Send/old') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/EndMessage') DROP MESSAGE TYPE [dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_aa7ae19e-4174-4e05-8135-3818a7ac8cd7_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Receiver') DROP SERVICE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender') DROP SERVICE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Receiver') DROP QUEUE [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender') DROP QUEUE [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6') DROP CONTRACT [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ID') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ID/old') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/FromUserID') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ToUserID') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Content') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Content/old') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/CreatedDate') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Send') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Send/old') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/EndMessage') DROP MESSAGE TYPE [dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_ac5bddc5-0e5a-44b4-b145-c14aa68ffdf6_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Receiver') DROP SERVICE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender') DROP SERVICE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Receiver') DROP QUEUE [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender') DROP QUEUE [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae') DROP CONTRACT [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ID') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ID/old') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/FromUserID') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ToUserID') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Content') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Content/old') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/CreatedDate') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Send') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Send/old') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/EndMessage') DROP MESSAGE TYPE [dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_adb333cc-eab5-42b1-94d9-ba249d324bae_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Receiver') DROP SERVICE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender') DROP SERVICE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Receiver') DROP QUEUE [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender') DROP QUEUE [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364') DROP CONTRACT [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ID') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ID/old') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/FromUserID') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ToUserID') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Content') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Content/old') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/CreatedDate') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Send') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Send/old') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/EndMessage') DROP MESSAGE TYPE [dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_adeac70c-bc28-4ea2-9c93-86eb17f6b364_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Receiver') DROP SERVICE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender') DROP SERVICE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Receiver') DROP QUEUE [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender') DROP QUEUE [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088') DROP CONTRACT [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ID') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ID/old') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/FromUserID') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ToUserID') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Content') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Content/old') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/CreatedDate') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Send') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Send/old') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/EndMessage') DROP MESSAGE TYPE [dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_b008068d-3eb9-4eb6-996f-d1fcb28fc088_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Receiver') DROP SERVICE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender') DROP SERVICE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Receiver') DROP QUEUE [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender') DROP QUEUE [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7') DROP CONTRACT [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ID') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ID/old') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/FromUserID') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ToUserID') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Content') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Content/old') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/CreatedDate') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Send') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Send/old') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/EndMessage') DROP MESSAGE TYPE [dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_b23d8f90-c21e-41c7-9985-31bd8e42b5b7_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Receiver') DROP SERVICE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender') DROP SERVICE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Receiver') DROP QUEUE [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender') DROP QUEUE [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82') DROP CONTRACT [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ID') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ID/old') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/FromUserID') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ToUserID') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Content') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Content/old') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/CreatedDate') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Send') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Send/old') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/EndMessage') DROP MESSAGE TYPE [dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_b4732877-1a21-4bc5-bc27-850dc9f91e82_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Receiver') DROP SERVICE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender') DROP SERVICE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Receiver') DROP QUEUE [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender') DROP QUEUE [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610') DROP CONTRACT [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ID') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ID/old') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/FromUserID') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ToUserID') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Content') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Content/old') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/CreatedDate') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Send') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Send/old') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/EndMessage') DROP MESSAGE TYPE [dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_b4c73c35-a1ed-4c65-a51f-725c29b31610_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Receiver') DROP SERVICE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender') DROP SERVICE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Receiver') DROP QUEUE [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender') DROP QUEUE [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f') DROP CONTRACT [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ID') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ID/old') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/FromUserID') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ToUserID') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Content') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Content/old') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/CreatedDate') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Send') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Send/old') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/EndMessage') DROP MESSAGE TYPE [dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_b61c3224-da71-4e32-940c-0fc697f0b18f_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Receiver') DROP SERVICE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender') DROP SERVICE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Receiver') DROP QUEUE [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender') DROP QUEUE [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170') DROP CONTRACT [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ID') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ID/old') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/FromUserID') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ToUserID') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Content') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Content/old') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/CreatedDate') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Send') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Send/old') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/EndMessage') DROP MESSAGE TYPE [dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_bd870812-7978-4acd-ad9f-aee917dfa170_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Receiver') DROP SERVICE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender') DROP SERVICE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Receiver') DROP QUEUE [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender') DROP QUEUE [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88') DROP CONTRACT [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ID') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ID/old') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/FromUserID') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ToUserID') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Content') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Content/old') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/CreatedDate') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Send') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Send/old') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/EndMessage') DROP MESSAGE TYPE [dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_c75f812e-d710-4396-b699-d5b35337ed88_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Receiver') DROP SERVICE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender') DROP SERVICE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Receiver') DROP QUEUE [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender') DROP QUEUE [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617') DROP CONTRACT [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ID') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ID/old') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/FromUserID') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ToUserID') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Content') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Content/old') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/CreatedDate') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Send') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Send/old') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/EndMessage') DROP MESSAGE TYPE [dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_c9ebd5b4-4758-42bb-8954-4fd1dbf94617_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Receiver') DROP SERVICE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender') DROP SERVICE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Receiver') DROP QUEUE [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender') DROP QUEUE [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b') DROP CONTRACT [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ID') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ID/old') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/FromUserID') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ToUserID') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Content') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Content/old') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/CreatedDate') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Send') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Send/old') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/EndMessage') DROP MESSAGE TYPE [dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_d45869ca-72f5-4d75-91fb-c09bf52ad74b_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Receiver') DROP SERVICE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender') DROP SERVICE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Receiver') DROP QUEUE [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender') DROP QUEUE [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26') DROP CONTRACT [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ID') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ID/old') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/FromUserID') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ToUserID') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Content') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Content/old') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/CreatedDate') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Send') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Send/old') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/EndMessage') DROP MESSAGE TYPE [dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_d6044bd9-9b84-4173-93ff-47cda7dadb26_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Receiver') DROP SERVICE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender') DROP SERVICE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Receiver') DROP QUEUE [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender') DROP QUEUE [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06') DROP CONTRACT [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ID') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ID/old') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/FromUserID') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ToUserID') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Content') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Content/old') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/CreatedDate') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Send') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Send/old') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/EndMessage') DROP MESSAGE TYPE [dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_e2269ff3-ab2e-4767-8714-9636c973ba06_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Receiver') DROP SERVICE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender') DROP SERVICE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Receiver') DROP QUEUE [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender') DROP QUEUE [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2') DROP CONTRACT [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ID') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ID/old') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/FromUserID') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ToUserID') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Content') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Content/old') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/CreatedDate') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Send') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Send/old') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/EndMessage') DROP MESSAGE TYPE [dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_e2fad369-4569-44ac-8bca-19059d4390b2_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Receiver') DROP SERVICE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender') DROP SERVICE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Receiver') DROP QUEUE [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender') DROP QUEUE [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed') DROP CONTRACT [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ID') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ID/old') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/FromUserID') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ToUserID') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Content') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Content/old') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/CreatedDate') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Send') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Send/old') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/EndMessage') DROP MESSAGE TYPE [dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_ebe907e4-4e42-4ebe-8587-4749e28916ed_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Receiver') DROP SERVICE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender') DROP SERVICE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Receiver') DROP QUEUE [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender') DROP QUEUE [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8') DROP CONTRACT [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ID') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ID/old') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/FromUserID') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ToUserID') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Content') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Content/old') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/CreatedDate') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Send') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Send/old') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/EndMessage') DROP MESSAGE TYPE [dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_f7cb2657-e38a-41a9-841a-86b7a400c3a8_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Receiver') DROP SERVICE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender') DROP SERVICE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Receiver') DROP QUEUE [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender') DROP QUEUE [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11') DROP CONTRACT [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ID') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ID/old') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/FromUserID') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ToUserID') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Content') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Content/old') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/CreatedDate') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Send') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Send/old') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/EndMessage') DROP MESSAGE TYPE [dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_f84a132a-8b4e-493d-82a5-5a00071fee11_QueueActivationSender];

        
    END
END
GO
/****** Object:  StoredProcedure [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_QueueActivationSender]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_QueueActivationSender] 
WITH EXECUTE AS SELF
AS 
BEGIN 
    SET NOCOUNT ON;
    DECLARE @h AS UNIQUEIDENTIFIER;
    DECLARE @mt NVARCHAR(200);

    RECEIVE TOP(1) @h = conversation_handle, @mt = message_type_name FROM [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender];

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
    BEGIN
        END CONVERSATION @h;
    END

    IF @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/DialogTimer' OR @mt = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
    BEGIN 
        

        END CONVERSATION @h;

        DECLARE @conversation_handle UNIQUEIDENTIFIER;
        DECLARE @schema_id INT;
        SELECT @schema_id = schema_id FROM sys.schemas WITH (NOLOCK) WHERE name = N'dbo';

        
        IF EXISTS (SELECT * FROM sys.triggers WITH (NOLOCK) WHERE object_id = OBJECT_ID(N'[dbo].[tr_dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender]')) DROP TRIGGER [dbo].[tr_dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender') EXEC (N'ALTER QUEUE [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender] WITH ACTIVATION (STATUS = OFF)');

        
        SELECT conversation_handle INTO #Conversations FROM sys.conversation_endpoints WITH (NOLOCK) WHERE far_service LIKE N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_%' ORDER BY is_initiator ASC;
        DECLARE conversation_cursor CURSOR FAST_FORWARD FOR SELECT conversation_handle FROM #Conversations;
        OPEN conversation_cursor;
        FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            END CONVERSATION @conversation_handle WITH CLEANUP;
            FETCH NEXT FROM conversation_cursor INTO @conversation_handle;
        END
        CLOSE conversation_cursor;
        DEALLOCATE conversation_cursor;
        DROP TABLE #Conversations;

        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Receiver') DROP SERVICE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Receiver];
        
        IF EXISTS (SELECT * FROM sys.services WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender') DROP SERVICE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Receiver') DROP QUEUE [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Receiver];
        
        IF EXISTS (SELECT * FROM sys.service_queues WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender') DROP QUEUE [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_Sender];

        
        IF EXISTS (SELECT * FROM sys.service_contracts WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0') DROP CONTRACT [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0];
        
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/StartMessage/Insert') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/StartMessage/Insert];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/StartMessage/Update') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/StartMessage/Update];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/StartMessage/Delete') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/StartMessage/Delete];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ID') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ID/old') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/FromUserID') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/FromUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/FromUserID/old') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/FromUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ToUserID') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ToUserID];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ToUserID/old') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/ToUserID/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Content') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Content];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Content/old') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Content/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/CreatedDate') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/CreatedDate];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/CreatedDate/old') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/CreatedDate/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Send') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Send];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Send/old') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/Send/old];
        IF EXISTS (SELECT * FROM sys.service_message_types WITH (NOLOCK) WHERE name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/EndMessage') DROP MESSAGE TYPE [dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0/EndMessage];

        
        IF EXISTS (SELECT * FROM sys.objects WITH (NOLOCK) WHERE schema_id = @schema_id AND name = N'dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_QueueActivationSender') DROP PROCEDURE [dbo].[dbo_Message_fda62318-ec7d-42a2-a6a1-dc1166f7dee0_QueueActivationSender];

        
    END
END
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Message]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Message](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FromUserID] [int] NULL,
	[ToUserID] [int] NULL,
	[Content] [nvarchar](500) NULL,
	[CreatedDate] [datetime] NULL,
	[Send] [bit] NULL,
 CONSTRAINT [PK_Message] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[ProductName] [nvarchar](50) NULL,
	[ProductPrice] [int] NULL,
	[Quantity] [int] NULL,
	[OrderID] [int] NULL,
	[ProductImage] [nvarchar](500) NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Orders]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[Status] [nvarchar](50) NULL,
	[DateOrder] [datetime] NULL,
	[DateShip] [datetime] NULL,
	[IsPaid] [bit] NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Products]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[Price] [int] NULL,
	[CreatedBy] [int] NULL,
	[ViewCount] [int] NULL,
	[Image1] [nvarchar](500) NULL,
	[Image2] [nvarchar](500) NULL,
	[Image3] [nvarchar](500) NULL,
	[Quantity] [int] NULL,
	[PurchasedCount] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CategoryID] [int] NULL,
	[Type] [nvarchar](50) NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[Email] [nvarchar](50) NULL,
	[Phone] [nchar](12) NULL,
	[UserTypeID] [int] NULL,
	[Password] [nvarchar](50) NULL,
	[Avatar] [nvarchar](50) NULL,
	[Address] [nvarchar](500) NULL,
	[IsConfirm] [bit] NULL,
	[Captcha] [nvarchar](50) NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserType]    Script Date: 11/1/2023 6:40:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_UserType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[Categories] ON 

INSERT [dbo].[Categories] ([ID], [Name], [IsActive]) VALUES (1006, N'Hoa hồng', 1)
INSERT [dbo].[Categories] ([ID], [Name], [IsActive]) VALUES (1007, N'Hoa lan', 1)
INSERT [dbo].[Categories] ([ID], [Name], [IsActive]) VALUES (1008, N'Hoa cúc', 1)
SET IDENTITY_INSERT [dbo].[Categories] OFF
SET IDENTITY_INSERT [dbo].[Message] ON 

INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (29, 2, 1, N'hi shop', CAST(N'2022-07-26 15:08:39.133' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (30, 2, 1, N'ấd', CAST(N'2022-07-26 15:08:49.193' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (31, 4, 1, N'hi shop', CAST(N'2022-07-28 20:57:06.260' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (32, 1, 4, N'chào bạn', CAST(N'2022-07-28 20:57:21.300' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (33, 4, 1, N'aaaaaaaaaaa', CAST(N'2022-07-28 20:57:27.650' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (34, 3, 1, N'ryut', CAST(N'2022-08-16 21:06:29.320' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (35, 3, 1, N'fgedfg', CAST(N'2022-08-16 21:06:35.967' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (36, 3, 1, N'asdasd', CAST(N'2022-08-16 21:06:38.037' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (37, 3, 1, N'dd', CAST(N'2022-08-16 21:07:04.450' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (38, 3, 1, N'oo', CAST(N'2022-08-16 21:09:04.690' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (39, 2, 1, N'dsa', CAST(N'2022-08-26 09:52:39.307' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (40, 2, 1, N'fdbdbf', CAST(N'2022-08-26 09:52:43.117' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (41, 2, 1, N'ewr', CAST(N'2022-08-26 09:52:46.790' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (42, 3, 1, N'htrh', CAST(N'2022-09-17 19:00:29.157' AS DateTime), 0)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (43, 1, 2, N'bfd', CAST(N'2023-11-01 18:22:31.640' AS DateTime), 1)
INSERT [dbo].[Message] ([ID], [FromUserID], [ToUserID], [Content], [CreatedDate], [Send]) VALUES (44, 1, 2, N'u65u6', CAST(N'2023-11-01 18:22:35.297' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Message] OFF
SET IDENTITY_INSERT [dbo].[OrderDetails] ON 

INSERT [dbo].[OrderDetails] ([ID], [ProductID], [ProductName], [ProductPrice], [Quantity], [OrderID], [ProductImage]) VALUES (9, 1, N'Face Jack Black Double-Duty Face', 28, 1, 9, N'71bJ8sbepzL._SX522_.jpg')
INSERT [dbo].[OrderDetails] ([ID], [ProductID], [ProductName], [ProductPrice], [Quantity], [OrderID], [ProductImage]) VALUES (10, 2, N'PCA SKIN Purifying Skin Care Face Mask', 50, 1, 10, N'61-cF2l6m2L._SY679_.jpg')
INSERT [dbo].[OrderDetails] ([ID], [ProductID], [ProductName], [ProductPrice], [Quantity], [OrderID], [ProductImage]) VALUES (12, 1, N'Face Jack Black Double-Duty Face', 28, 1, 12, N'71bJ8sbepzL._SX522_.jpg')
INSERT [dbo].[OrderDetails] ([ID], [ProductID], [ProductName], [ProductPrice], [Quantity], [OrderID], [ProductImage]) VALUES (13, 1, N'Face Jack Black Double-Duty Face', 28, 1, 13, N'71bJ8sbepzL._SX522_.jpg')
INSERT [dbo].[OrderDetails] ([ID], [ProductID], [ProductName], [ProductPrice], [Quantity], [OrderID], [ProductImage]) VALUES (14, 4, N'Cam sành (1Kg)', 28000, 2, 14, N'cam-sanh-loai-1kg.jpg')
INSERT [dbo].[OrderDetails] ([ID], [ProductID], [ProductName], [ProductPrice], [Quantity], [OrderID], [ProductImage]) VALUES (15, 2, N'Vườn hồng', 600000, 1, 15, N'hoa-cuoi-hong-trang.jpg')
SET IDENTITY_INSERT [dbo].[OrderDetails] OFF
SET IDENTITY_INSERT [dbo].[Orders] ON 

INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (7, 3, N'Complete', CAST(N'2022-09-18 17:59:08.713' AS DateTime), CAST(N'2022-09-22 16:40:15.837' AS DateTime), 0)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (8, 3, N'Complete', CAST(N'2022-09-18 17:59:12.723' AS DateTime), CAST(N'2022-09-22 16:40:17.763' AS DateTime), 0)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (9, 3, N'Complete', CAST(N'2022-09-18 18:01:04.527' AS DateTime), CAST(N'2022-09-22 16:40:18.913' AS DateTime), 0)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (10, 3, N'Complete', CAST(N'2022-09-18 18:05:00.083' AS DateTime), CAST(N'2022-09-22 16:40:20.010' AS DateTime), 0)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (11, 3, N'Complete', CAST(N'2022-09-18 18:06:48.697' AS DateTime), CAST(N'2022-09-22 16:40:21.067' AS DateTime), 0)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (12, 3, N'Complete', CAST(N'2022-09-18 18:10:25.793' AS DateTime), CAST(N'2022-09-22 16:40:22.113' AS DateTime), 0)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (13, 3, N'Complete', CAST(N'2022-09-18 18:11:39.153' AS DateTime), CAST(N'2022-09-22 16:40:23.257' AS DateTime), 1)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (14, 3, N'Processing', CAST(N'2022-12-04 20:43:06.443' AS DateTime), CAST(N'2022-12-07 20:43:06.443' AS DateTime), 1)
INSERT [dbo].[Orders] ([ID], [UserID], [Status], [DateOrder], [DateShip], [IsPaid]) VALUES (15, 1, N'Processing', CAST(N'2023-11-01 18:32:33.867' AS DateTime), CAST(N'2023-11-04 18:32:33.867' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[Orders] OFF
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([ID], [Name], [Price], [CreatedBy], [ViewCount], [Image1], [Image2], [Image3], [Quantity], [PurchasedCount], [Description], [IsActive], [CategoryID], [Type]) VALUES (1, N'Hoa hồng cho em', 1400000, 1, 0, N'hoa-hong-cho-em-1400.jpg', N'hoa-hong-cho-em-1400.jpg', N'hoa-hong-cho-em-1400.jpg', 10, 10, N'Hoa Ngày Quốc Tế Phụ Nữ Việt Nam: 
màu sắc các loại hoa: 
Hoa sự kiện: Hoa Ngày Quốc Tế Phụ Nữ Việt Nam 8/3Hoa ngày Valentine 14/02Hoa mừng ngày Giáng Sinh
Bó hoa  được tạo nên từ những hoa màu hồng thích hợp làm quà tặng cho các dịp chúc muừng sinh nhật, hoa ngày 8-3, hoa ngày 20-10, tặng các dịp lễ tình nhân.

- 99cành Hoa Hồng

- Các loại Hoa và Lá khác', 1, 1006, N'Oliy')
INSERT [dbo].[Products] ([ID], [Name], [Price], [CreatedBy], [ViewCount], [Image1], [Image2], [Image3], [Quantity], [PurchasedCount], [Description], [IsActive], [CategoryID], [Type]) VALUES (2, N'Vườn hồng', 600000, 1, 0, N'hoa-cuoi-hong-trang.jpg', N'hoa-cuoi-hong-trang.jpg', N'hoa-cuoi-hong-trang.jpg', 50, 3, N'Hoa Ngày Quốc Tế Phụ Nữ Việt Nam: 
Bó hoa cưới Vườn hồng tượng trưng cho sự gắn kết lâu bền trong ngày trọng đại và hạnh phúc bền lâu.', 1, 1006, N'Combination')
INSERT [dbo].[Products] ([ID], [Name], [Price], [CreatedBy], [ViewCount], [Image1], [Image2], [Image3], [Quantity], [PurchasedCount], [Description], [IsActive], [CategoryID], [Type]) VALUES (3, N'Bó hồng vàng', 350000, 1, 0, N'dien-hoa-can-tho-350.jpg', N'dien-hoa-can-tho-350.jpg', N'dien-hoa-can-tho-350.jpg', 200, 3, N'Hoa Ngày Quốc Tế Phụ Nữ Việt Nam: 
Bó hoa  được tạo nên từ những bông hoa hồng phấn thích hợp làm quà tặng cho các dịp chúc muừng sinh nhật, hoa ngày 8-3, hoa ngày 20-10, tặng các dịp lễ tình nhân.
Bó hồng cho em như một lời hứa hẹn', 1, 1006, N'Combination')
INSERT [dbo].[Products] ([ID], [Name], [Price], [CreatedBy], [ViewCount], [Image1], [Image2], [Image3], [Quantity], [PurchasedCount], [Description], [IsActive], [CategoryID], [Type]) VALUES (4, N'Rising', 1200000, 1, 0, N'rising.jpeg', N'rising.jpeg', N'rising.jpeg', 100, 5, N'Hoa Ngày Quốc Tế Phụ Nữ Việt Nam: 
màu sắc các loại hoa: 
- Hoa Hồng

- Cẩm Chướng

- Hướng Dương

- Các loại hoa và lá khác

- Giấy gói hồng nhạt

- Băng rôn/ banner đính kèm', 1, 1008, N'Combination')
INSERT [dbo].[Products] ([ID], [Name], [Price], [CreatedBy], [ViewCount], [Image1], [Image2], [Image3], [Quantity], [PurchasedCount], [Description], [IsActive], [CategoryID], [Type]) VALUES (5, N'Hướng dương và lan', 700000, 1, 0, N'huong-duong-va-lan-700.jpg', N'huong-duong-va-lan-700.jpg', N'huong-duong-va-lan-700.jpg', 10, 1, N'Hoa Ngày Quốc Tế Phụ Nữ Việt Nam: 
màu sắc các loại hoa: 
Bó hoa  được tạo nên từ những hoa hướng dương rực rở thích hợp làm quà tặng cho các dịp chúc muừng sinh nhật, hoa ngày 8-3, hoa ngày 20-10, tặng các dịp lễ tình nhân.', 1, 1007, N'Combination')
INSERT [dbo].[Products] ([ID], [Name], [Price], [CreatedBy], [ViewCount], [Image1], [Image2], [Image3], [Quantity], [PurchasedCount], [Description], [IsActive], [CategoryID], [Type]) VALUES (17, N'Hoa lan tình yêu', 800000, 1, 0, N'hoa-lan-tinh-yeu2.jpg', N'', N'', 200, 1, N'Hoa Ngày Quốc Tế Phụ Nữ Việt Nam: 
màu sắc các loại hoa: 
Bó hoa  được tạo nên từ những hoa hồng tươi thích hợp làm quà tặng cho các dịp chúc muừng sinh nhật, hoa ngày 8-3, hoa ngày 20-10, tặng các dịp lễ tình nhân.', 1, 1007, NULL)
SET IDENTITY_INSERT [dbo].[Products] OFF
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([ID], [Name], [Email], [Phone], [UserTypeID], [Password], [Avatar], [Address], [IsConfirm], [Captcha]) VALUES (1, N'Admin', N'admin@gmail.com', N'1234567890  ', 1, N'123456', N'admin.jfif', N'Can Tho', NULL, NULL)
INSERT [dbo].[Users] ([ID], [Name], [Email], [Phone], [UserTypeID], [Password], [Avatar], [Address], [IsConfirm], [Captcha]) VALUES (2, N'Nguyễn Văn B', N'nvb@gmail.com', N'0907892198  ', 2, N'123456', N'user.jpg', N'Can Tho', NULL, NULL)
INSERT [dbo].[Users] ([ID], [Name], [Email], [Phone], [UserTypeID], [Password], [Avatar], [Address], [IsConfirm], [Captcha]) VALUES (3, N'Nguyen Van A', N'nva@gmail.com', N'1234567890  ', 2, N'123456', NULL, N'eeeeefdsf', NULL, NULL)
INSERT [dbo].[Users] ([ID], [Name], [Email], [Phone], [UserTypeID], [Password], [Avatar], [Address], [IsConfirm], [Captcha]) VALUES (4, N'Nguyen Nguyen', N'nguyen@gmail.com', N'1234567890  ', 2, N'123456', NULL, N'user.jpg', NULL, NULL)
INSERT [dbo].[Users] ([ID], [Name], [Email], [Phone], [UserTypeID], [Password], [Avatar], [Address], [IsConfirm], [Captcha]) VALUES (10, N'dsfsf', N'nlkhuong1800120@student.ctuet.edu.vn', N'123         ', 2, N'123', NULL, N'pr.jpg', 1, N'360551')
INSERT [dbo].[Users] ([ID], [Name], [Email], [Phone], [UserTypeID], [Password], [Avatar], [Address], [IsConfirm], [Captcha]) VALUES (11, N'khuong nguyen', N'lapankhuongnguyen@gmail.com', N'1234567893  ', 2, N'123456', NULL, N'pr.jpg', 1, N'734273')
SET IDENTITY_INSERT [dbo].[Users] OFF
SET IDENTITY_INSERT [dbo].[UserType] ON 

INSERT [dbo].[UserType] ([ID], [Name]) VALUES (1, N'Admin')
INSERT [dbo].[UserType] ([ID], [Name]) VALUES (2, N'Client')
SET IDENTITY_INSERT [dbo].[UserType] OFF
ALTER TABLE [dbo].[Message]  WITH CHECK ADD  CONSTRAINT [FK__Message__FromUse__36B12243] FOREIGN KEY([FromUserID])
REFERENCES [dbo].[Users] ([ID])
GO
ALTER TABLE [dbo].[Message] CHECK CONSTRAINT [FK__Message__FromUse__36B12243]
GO
ALTER TABLE [dbo].[Message]  WITH CHECK ADD  CONSTRAINT [FK__Message__ToUserI__37A5467C] FOREIGN KEY([ToUserID])
REFERENCES [dbo].[Users] ([ID])
GO
ALTER TABLE [dbo].[Message] CHECK CONSTRAINT [FK__Message__ToUserI__37A5467C]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK__OrderDeta__Order__25869641] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([ID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK__OrderDeta__Order__25869641]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK__OrderDeta__Produ__24927208] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK__OrderDeta__Produ__24927208]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([UserID])
REFERENCES [dbo].[Users] ([ID])
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK__Products__Catego__239E4DCF] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([ID])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK__Products__Catego__239E4DCF]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK__Products__Create__276EDEB3] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[Users] ([ID])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK__Products__Create__276EDEB3]
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD FOREIGN KEY([UserTypeID])
REFERENCES [dbo].[UserType] ([ID])
GO
USE [master]
GO
ALTER DATABASE [flower-store] SET  READ_WRITE 
GO
