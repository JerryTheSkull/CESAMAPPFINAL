-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1
-- Généré le : sam. 06 sep. 2025 à 20:22
-- Version du serveur : 10.4.32-MariaDB
-- Version de PHP : 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cesam_laravel_try2`
--

-- --------------------------------------------------------

--
-- Structure de la table `applications`
--

CREATE TABLE `applications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `offer_id` bigint(20) UNSIGNED NOT NULL,
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `applications`
--

INSERT INTO `applications` (`id`, `user_id`, `offer_id`, `applied_at`, `created_at`, `updated_at`) VALUES
(3, 2, 3, '2025-09-06 10:01:01', '2025-09-06 10:01:01', '2025-09-06 10:01:01'),
(4, 2, 4, '2025-09-06 15:29:03', '2025-09-06 15:29:03', '2025-09-06 15:29:03');

-- --------------------------------------------------------

--
-- Structure de la table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(54, 'default', '{\"uuid\":\"f16ba8ff-bd56-4b0c-a3f0-f1f67555e4bd\",\"displayName\":\"App\\\\Mail\\\\PasswordResetCodeMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":15:{s:8:\\\"mailable\\\";O:30:\\\"App\\\\Mail\\\\PasswordResetCodeMail\\\":4:{s:4:\\\"code\\\";s:6:\\\"924519\\\";s:9:\\\"userEmail\\\";s:31:\\\"ravaosolomarguerite66@gmail.com\\\";s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:31:\\\"ravaosolomarguerite66@gmail.com\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\"}}', 0, NULL, 1757047818, 1757047818),
(55, 'default', '{\"uuid\":\"8f28bf56-6da6-44ee-8eaf-5781d6f1f5b7\",\"displayName\":\"App\\\\Mail\\\\PasswordResetCodeMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":15:{s:8:\\\"mailable\\\";O:30:\\\"App\\\\Mail\\\\PasswordResetCodeMail\\\":4:{s:4:\\\"code\\\";s:6:\\\"123456\\\";s:9:\\\"userEmail\\\";s:31:\\\"ravaosolomarguerite66@gmail.com\\\";s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:31:\\\"ravaosolomarguerite66@gmail.com\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\"}}', 0, NULL, 1757048100, 1757048100);

-- --------------------------------------------------------

--
-- Structure de la table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `likes`
--

CREATE TABLE `likes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `video_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `likes`
--

INSERT INTO `likes` (`id`, `created_at`, `updated_at`, `user_id`, `video_id`) VALUES
(4, '2025-09-06 07:55:19', '2025-09-06 07:55:19', 2, 3),
(5, '2025-09-06 15:48:02', '2025-09-06 15:48:02', 15, 3);

-- --------------------------------------------------------

--
-- Structure de la table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2025_07_23_234537_create_permission_tables', 1),
(5, '2025_07_24_003254_create_user_profiles_table', 1),
(6, '2025_07_24_110727_create_types_competences_table', 1),
(7, '2025_07_24_110736_create_projets_table', 1),
(8, '2025_07_24_111704_create_competences_table', 1),
(9, '2025_07_26_232828_add_soft_deletes_to_users_table', 1),
(10, '2025_08_06_114131_add_is_approved_to_users_table', 1),
(11, '2025_08_06_115049_create_projects_table', 1),
(12, '2025_08_06_123556_remove_role_from_users_table', 1),
(13, '2025_08_07_235605_add_missing_columns_to_users_table', 1),
(14, '2025_08_08_002323_add_verification_code_expires_at_to_users', 1),
(15, '2025_08_17_185129_create_registration_processes_table', 1),
(16, '2025_08_17_185208_create_registration_step_data_table', 1),
(17, '2025_08_17_185219_create_registration_audit_logs_table', 1),
(18, '2025_08_17_185228_add_registration_fields_to_users_table', 1),
(19, '2025_08_17_235821_add_missing_fields_to_users_table', 1),
(20, '2025_08_19_055607_make_nom_complet_nullable_in_users_table', 1),
(21, '2025_08_19_060928_add_email_verified_at_to_users_table', 1),
(22, '2025_08_21_120456_add_profile_image_url_to_users_table', 1),
(23, '2025_08_22_201736_create_scholarships_table', 1),
(24, '2025_08_27_192827_create_reports_table', 1),
(25, '2025_08_29_155807_add_matricule_amci_to_users_table', 1),
(26, '2025_08_29_164810_rename_field_to_domain_in_reports_table', 1),
(27, '2025_08_30_023034_add_remember_token_to_users_table', 1),
(28, '2025_08_30_023523_add_status_to_users_table', 1),
(29, '2025_08_30_024841_alter_registration_status_in_users_table', 1),
(30, '2025_08_30_031141_update_registration_status_enum_in_users_table', 1),
(31, '2025_08_31_150235_create_videos_table', 2),
(33, '2025_08_31_161615_create_likes_table', 3),
(34, '2025_08_31_165725_add_columns_to_videos_table', 4),
(35, '2025_08_31_174636_add_columns_to_likes_table', 5),
(36, '2025_08_31_224952_convert_projects_to_json_in_users_table', 6),
(37, '2025_09_02_150544_create_offers_table', 7),
(38, '2025_09_02_150601_create_applications_table', 7),
(39, '2025_09_03_205148_create_password_reset_codes_table', 8),
(41, '2025_09_04_052842_create_quotes_table', 9),
(42, '2025_09_05_044724_add_token_to_password_reset_codes_table', 10);

-- --------------------------------------------------------

--
-- Structure de la table `model_has_permissions`
--

CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `model_has_roles`
--

CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) UNSIGNED NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `model_has_roles`
--

INSERT INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES
(1, 'App\\Models\\User', 2),
(1, 'App\\Models\\User', 10),
(1, 'App\\Models\\User', 14),
(2, 'App\\Models\\User', 1),
(2, 'App\\Models\\User', 3),
(2, 'App\\Models\\User', 4),
(2, 'App\\Models\\User', 5),
(2, 'App\\Models\\User', 6),
(2, 'App\\Models\\User', 7),
(2, 'App\\Models\\User', 8),
(2, 'App\\Models\\User', 9),
(2, 'App\\Models\\User', 11),
(2, 'App\\Models\\User', 12),
(2, 'App\\Models\\User', 13),
(2, 'App\\Models\\User', 15);

-- --------------------------------------------------------

--
-- Structure de la table `notifications`
--

CREATE TABLE `notifications` (
  `id` char(36) NOT NULL,
  `type` varchar(255) NOT NULL,
  `notifiable_type` varchar(255) NOT NULL,
  `notifiable_id` bigint(20) UNSIGNED NOT NULL,
  `data` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `notifications`
--

INSERT INTO `notifications` (`id`, `type`, `notifiable_type`, `notifiable_id`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
('03f93b93-7a6d-4aa6-9706-0e89a55178af', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 4, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:44', '2025-09-05 01:24:44'),
('0da78571-a530-4010-a0eb-98131b0726bd', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 13, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:35', '2025-09-05 01:24:35'),
('1b361022-4a56-4476-b2e3-bf4210714c3d', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 2, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:13', '2025-09-05 01:24:13'),
('23270715-2d0a-4a83-bd16-a85fe0089fa2', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 7, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:25', '2025-09-05 01:24:25'),
('24493631-2694-4b1b-bf2c-c99da96b350e', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 2, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:41', '2025-09-05 01:24:41'),
('338add4a-388b-447e-92ca-8dc1b330ba2a', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 3, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:16', '2025-09-05 01:24:16'),
('446984e0-40f5-4652-a087-537b9d0e98a8', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 7, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:51', '2025-09-05 01:24:51'),
('44aa7338-b5ea-44c8-9616-9925aef8ec53', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 3, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:43', '2025-09-05 01:24:43'),
('4836c9ee-8257-485b-bd58-5bedb0717886', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 10, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:55', '2025-09-05 01:24:55'),
('5d1a3f62-6500-41ba-9e89-bfe8547883b1', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 12, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:56', '2025-09-05 01:24:56'),
('72b772d8-b44f-4e91-873e-63fcbb9dd41f', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 10, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:31', '2025-09-05 01:24:31'),
('8308c053-b90c-41a3-861a-3fed08b7b688', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 6, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:23', '2025-09-05 01:24:23'),
('83236393-c3a0-47fe-9c31-48263dadab5b', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 13, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:57', '2025-09-05 01:24:57'),
('9cc9670a-d2e9-4dd1-85b0-dd2d766f7782', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 6, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:49', '2025-09-05 01:24:49'),
('a11aa052-66ff-4d52-b1b4-3376917b63e8', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 1, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:38', '2025-09-05 01:24:38'),
('abbbbb80-6129-4eea-b14c-fdf82ec8e97a', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 9, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:28', '2025-09-05 01:24:28'),
('adc76896-560c-4728-86da-47732ee80e5d', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 5, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:21', '2025-09-05 01:24:21'),
('b09325a5-2944-4106-b6fc-187169b217e7', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 14, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:36', '2025-09-05 01:24:36'),
('bec5dba4-5d4a-43c1-82c8-b70c3eb67716', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 1, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:02', '2025-09-05 01:24:02'),
('db4dca6d-9b9e-40dc-a157-8021548b46f1', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 9, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:54', '2025-09-05 01:24:54'),
('dc735413-59de-46eb-8497-05a371f79030', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 4, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:18', '2025-09-05 01:24:18'),
('e0746fa8-a625-4de8-afca-e305c347b9fe', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 12, '{\"quote_id\":1,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Il faut travailler pour r\\u00e9ussir\\\"\",\"quote_author\":\"chanteur\",\"published_at\":\"2025-09-05T01:05:56.000000Z\"}', NULL, '2025-09-05 01:24:33', '2025-09-05 01:24:33'),
('fa1560a1-9f77-4286-95c3-fd44cc09b7ac', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 14, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:59', '2025-09-05 01:24:59'),
('fe849a91-efa8-4251-ba72-18c1606dbde8', 'App\\Notifications\\QuotePublishedNotification', 'App\\Models\\User', 5, '{\"quote_id\":4,\"message\":\"Nouvelle citation publi\\u00e9e\",\"quote_text\":\"\\\"Femme forte \\\"\",\"quote_author\":\"moi\",\"published_at\":\"2025-09-05T01:05:36.000000Z\"}', NULL, '2025-09-05 01:24:47', '2025-09-05 01:24:47');

-- --------------------------------------------------------

--
-- Structure de la table `offers`
--

CREATE TABLE `offers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `type` enum('stage','emploi') NOT NULL,
  `description` text NOT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`links`)),
  `pdfs` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`pdfs`)),
  `published_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `offers`
--

INSERT INTO `offers` (`id`, `title`, `type`, `description`, `images`, `links`, `pdfs`, `published_at`, `is_active`, `created_at`, `updated_at`) VALUES
(3, 'gshsjus djkdkskd', 'stage', 'sghsjs sjsjsj djjsjs', NULL, NULL, NULL, '2025-09-06 10:00:47', 1, '2025-09-06 10:00:47', '2025-09-06 10:00:47'),
(4, 'shshjsjs djdkdk dkdknd dnskkd', 'stage', 'shjsjsj dkdkld dkkdkd dkkdkd skskndnd', NULL, NULL, NULL, '2025-09-06 15:16:21', 1, '2025-09-06 15:16:21', '2025-09-06 15:16:21'),
(5, 'dfsghsjsk djjdjdkks duisidkjz', 'stage', 'fsghsyyeye dhjdjdjud dujdiidod dhjduuzjzcsghuzuue dhjdjdkksj shjsjsj', NULL, NULL, NULL, '2025-09-06 15:30:06', 1, '2025-09-06 15:30:06', '2025-09-06 15:30:06'),
(6, 'gdhjdkdk djjdidi dudikd', 'stage', 'schsjdkkld djkdkdk dkkdkd', NULL, NULL, NULL, '2025-09-06 15:30:33', 1, '2025-09-06 15:30:33', '2025-09-06 15:30:33');

-- --------------------------------------------------------

--
-- Structure de la table `password_reset_codes`
--

CREATE TABLE `password_reset_codes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `code` varchar(6) NOT NULL,
  `token` varchar(255) DEFAULT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `attempts` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `password_reset_codes`
--

INSERT INTO `password_reset_codes` (`id`, `email`, `code`, `token`, `expires_at`, `attempts`, `created_at`, `updated_at`) VALUES
(11, 'test@example.com', '295024', 't3oKe5WN7larAf7vt2CsMlkMZqZGYIUMWKblpgsvZAOH3uQuNFxfa91iRjqQpwuO', '2025-09-05 08:52:13', 2, '2025-09-05 06:49:42', '2025-09-05 06:52:13');

-- --------------------------------------------------------

--
-- Structure de la table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `permissions`
--

CREATE TABLE `permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `permissions`
--

INSERT INTO `permissions` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'view_users', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(2, 'create_users', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(3, 'edit_users', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(4, 'delete_users', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(5, 'manage_roles', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(6, 'view_profile', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(7, 'edit_profile', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(8, 'delete_profile', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41');

-- --------------------------------------------------------

--
-- Structure de la table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(32, 'App\\Models\\User', 9, 'auth-token', '17ed0b254282d38df8130495c634b5bb8eaf0671750c28b481f9c4cd010cf661', '[\"*\"]', '2025-08-31 03:52:39', NULL, '2025-08-31 03:51:26', '2025-08-31 03:52:39'),
(47, 'App\\Models\\User', 10, 'auth-token', 'fd6f0943d60854b25112aee4efe6edb4fe7fb60e788fba08d288f1fcba026403', '[\"*\"]', '2025-08-31 20:25:04', NULL, '2025-08-31 20:24:46', '2025-08-31 20:25:04'),
(56, 'App\\Models\\User', 11, 'auth-token', '4f862cd94300b413a108a01ff2e986f501acba3fdd07bb5d2665e70910b10b08', '[\"*\"]', '2025-09-01 08:18:05', NULL, '2025-09-01 08:17:57', '2025-09-01 08:18:05'),
(115, 'App\\Models\\User', 12, 'auth-token', '9d745256dda5e40aa309259163fa60460b6325c160691f6eeb3ffc5b49b02123', '[\"*\"]', NULL, NULL, '2025-09-05 07:43:10', '2025-09-05 07:43:10'),
(161, 'App\\Models\\User', 15, 'auth-token', 'e0fdf38300223add194f946f6090115bc3bd02b8702d85f8ce26b7e7756e6ca7', '[\"*\"]', '2025-09-06 15:49:18', NULL, '2025-09-06 15:47:52', '2025-09-06 15:49:18'),
(164, 'App\\Models\\User', 2, 'auth-token', '86787e3b007cb9aebc2434dd46d5d7dc1c6711dc2441c6335a830862d703acd9', '[\"*\"]', '2025-09-06 16:11:48', NULL, '2025-09-06 16:11:43', '2025-09-06 16:11:48');

-- --------------------------------------------------------

--
-- Structure de la table `projects`
--

CREATE TABLE `projects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `link` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `projets`
--

CREATE TABLE `projets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `lien` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `quotes`
--

CREATE TABLE `quotes` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `text` text NOT NULL,
  `author` varchar(255) NOT NULL,
  `submitted_by` bigint(20) UNSIGNED NOT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `quotes`
--

INSERT INTO `quotes` (`id`, `text`, `author`, `submitted_by`, `is_published`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, '\"Il faut travailler pour réussir\"', 'chanteur', 2, 1, '2025-09-04 08:30:03', '2025-09-04 23:05:56', '2025-09-04 23:05:56'),
(2, 'sbsbs dkdkek ekekek', 'hzjzjz', 2, 0, '2025-09-04 08:31:34', '2025-09-04 08:31:34', NULL),
(3, 'La vie est dure ein', 'Moi', 2, 0, '2025-09-04 08:39:56', '2025-09-04 08:39:56', NULL),
(4, '\"Femme forte \"', 'moi', 2, 1, '2025-09-04 23:05:32', '2025-09-04 23:05:36', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `registration_audit_logs`
--

CREATE TABLE `registration_audit_logs` (
  `id` char(36) NOT NULL,
  `process_id` char(36) NOT NULL,
  `action` varchar(50) NOT NULL,
  `step_number` int(11) DEFAULT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `registration_audit_logs`
--

INSERT INTO `registration_audit_logs` (`id`, `process_id`, `action`, `step_number`, `data`, `ip_address`, `user_agent`, `created_at`, `updated_at`) VALUES
('005fde97-dc2d-4886-b989-1d65d81860a5', 'ea75fc5d-5216-4bb0-962c-7898728a0beb', 'step_completed', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123546789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$D5YxCfv8Sw5pHDxKu0BQPeLpf6yw5wxgGhobQ4Q1457h9D55.EGei\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 05:29:36', '2025-09-01 05:29:36'),
('00ed602c-cde5-4618-bcd6-bacd7990eb05', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true,\"email_sent\":true}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:10:36', '2025-09-05 23:10:36'),
('03aeeabb-d1a2-42c2-b514-3f7b8e919108', '70a80207-3800-47cb-8b0b-2cef290ae030', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:11:23', '2025-09-05 21:11:23'),
('064de18b-4a00-4194-b666-21ff0cdd04c6', 'e2b37756-5a36-4412-ab35-06fd863cdcdc', 'step_completed', 2, '{\"ecole\":\"sghsjs\",\"filiere\":\"zghsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"F\\u00e8s\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:37:07', '2025-09-01 07:37:07'),
('066a9b0c-998e-4db7-b848-32a7849e9515', '5394c165-7eba-4039-b986-9b73d83d63d8', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:13:44', '2025-09-02 09:13:44'),
('07a34dce-2b72-4f3e-bbf7-8dc8f35979b5', '976533e3-a507-4b18-9b13-e756fd67ed2f', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:55:41', '2025-09-02 10:55:41'),
('0961f3d3-7df4-42f9-bb90-1cc2ad43f499', '9530fcc7-3d10-42b6-82c3-9e0384376364', 'step_completed', 1, '{\"nom_complet\":\"shjsjs sjsks\",\"email\":\"fshs@hdj.hj\",\"telephone\":\"123456789\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$SAaMMk3b0BU1pmRoOT7KheSsmGa87TBN3XWMbyEArYFzZe8NFRBKy\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:08:01', '2025-09-02 11:08:01'),
('0d856a4a-6b68-414f-9518-b29245adf9c1', '5394c165-7eba-4039-b986-9b73d83d63d8', 'step_completed', 2, '{\"ecole\":\"shjsjsjs\",\"filiere\":\"shsjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Dakhla\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:13:11', '2025-09-02 09:13:11'),
('0e213f88-7f06-4e22-9a32-4c1274e0e9a6', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'step_completed', 2, '{\"ecole\":\"wvsvbs\",\"filiere\":\"gshhs\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:26:44', '2025-09-02 11:26:44'),
('0ea89525-567a-483c-b4e6-ae377ace3456', '6cdb793c-96e8-4aae-8382-a140824f64bb', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:52:45', '2025-09-05 22:52:45'),
('119665b8-3a79-42d2-8780-d4e48186c76f', 'f08fee38-a6f1-46d3-8959-7f5311cf356b', 'step_completed', 1, '{\"nom_complet\":\"xcghhj\",\"email\":\"xfff@ffg.hj\",\"telephone\":\"555225585\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$1FBF21DMmliBBL5csKBbE.HIRQhobh4INjHA3z3mUkFsYsczWhkW2\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:58:30', '2025-09-05 22:58:30'),
('12dae87e-fc12-4043-9af6-08b7361a6c4e', 'bf3413ae-7489-4b53-ac28-2309529dfe9c', 'step_completed', 2, '{\"ecole\":\"tetyeue\",\"filiere\":\"yzyzuzu\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Chefchaouen\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:57:32', '2025-09-01 07:57:32'),
('14201633-7be4-40eb-a41a-ac6ba912bad6', 'a9eed21f-6edd-4bcd-94c5-eff032f01d71', 'step_completed', 1, '{\"nom_complet\":\"gshsjs\",\"email\":\"sghsjs@sgsj.djdk\",\"telephone\":\"543464546461\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$IkwpQ.7ShJgAt1\\/2dxrjv.r19fIF\\/4eyF6ufwNqRk.FVn1XIJrhuG\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:12:40', '2025-09-02 12:12:40'),
('192d4d69-c3b2-4d1d-b07a-156843c5ef97', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 'step_completed', 2, '{\"ecole\":\"gshsjs\",\"filiere\":\"svjsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:15:21', '2025-09-02 11:15:21'),
('1b815520-a95e-48a9-97e5-873164ddb415', '1715055c-3cae-438d-b65d-5f4c4aed730c', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:00:18', '2025-09-02 11:00:18'),
('1b9c68ae-fcfa-4d3f-9903-7ead07af6c93', 'a9eed21f-6edd-4bcd-94c5-eff032f01d71', 'step_completed', 2, '{\"ecole\":\"sgsjksks\",\"filiere\":\"sshjsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:12:50', '2025-09-02 12:12:50'),
('1f352e9e-fb25-4ad8-b16c-ccac80c55e87', 'e98c4e2d-9594-4097-8eea-871e464519a0', 'step_completed', 2, '{\"ecole\":\"fhjjk\",\"filiere\":\"ghjj\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Errachidia\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:27:49', '2025-09-02 12:27:49'),
('1f6b66b7-7cda-40ba-ac8f-691af4aa4e10', '3d6a52fb-6e97-415c-93a2-1fd1902d6439', 'step_completed', 1, '{\"nom_complet\":\"hwbwksks dkld\",\"email\":\"sgsjjsj@vjdkd.djdj\",\"telephone\":\"46435464643\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$DbUkY0s9FNTb1RyzPe9eTuMGpXAT3bJ7ov1N4507w4QooCtMMTTMK\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:19:47', '2025-09-05 21:19:47'),
('20183113-8352-4796-b011-95bdfcf81137', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 'step_completed', 4, '{\"code_amci\":\"ET2003\",\"affilie_amci\":true,\"email_sent\":true}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 08:23:29', '2025-09-02 08:23:29'),
('215bd37b-a091-4d7e-a2c7-5cd402112501', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 1, '{\"nom_complet\":\"zhjdkdkd\",\"email\":\"rimkadelorodg@gmail.com\",\"telephone\":\"12318467994\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$LoSFnLFvw9Qa5xAB0tHfSOOuLw635fT3fq1JAow8csORb27W0NlvK\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:09:54', '2025-09-05 23:09:54'),
('220b361c-44a7-4a79-a4ed-7eb0977a3913', '81af45a1-07f0-4f52-aa39-6116d1ad216a', 'step_completed', 1, '{\"nom_complet\":\"fghhh hjjj\",\"email\":\"fgghjj@fgh.bh\",\"telephone\":\"225125556\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$gCXaWKvJhR8gyvqrF0RasuFAm0DzxEjxKPLxwQbOZXtBKE5lqS4ci\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:44:37', '2025-09-05 22:44:37'),
('22a7b826-6764-460a-be8a-26ea4440971e', '70a80207-3800-47cb-8b0b-2cef290ae030', 'step_completed', 2, '{\"ecole\":\"sghsjs djdkkd jskkd\",\"filiere\":\"zhzjsj dkdkkd\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:11:19', '2025-09-05 21:11:19'),
('23359aa4-5839-4c2d-b975-fa174b565719', '418d80ef-c9c7-4931-9e88-d4e27de84763', 'step_completed', 2, '{\"ecole\":\"ghjkkxghju\",\"filiere\":\"fghhh\",\"niveau_etude\":\"Master 1\",\"ville\":\"Errachidia\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:25:27', '2025-09-05 21:25:27'),
('24dfb04a-73d7-4af9-b259-b91e0f90a945', 'e2b37756-5a36-4412-ab35-06fd863cdcdc', 'step_completed', 1, '{\"nom_complet\":\"Vvsbs djsjsj\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$5gvlJnbvAA88CVElDXuciOixDBUML5U2ecrBWNd6KSI46xocMfPo6\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:36:57', '2025-09-01 07:36:57'),
('281ede7b-425a-4428-8173-9bcd7fe18604', 'e289004a-5c97-428b-8711-f18970e5ca37', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:25:37', '2025-09-02 09:25:37'),
('2bc725ca-282d-4939-a41f-abeb40337098', 'e289004a-5c97-428b-8711-f18970e5ca37', 'step_completed', 2, '{\"ecole\":\"hsjsksk\",\"filiere\":\"zhsjsjkd\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:25:26', '2025-09-02 09:25:26'),
('2ea3518f-4107-45e8-860a-b7be409da14e', 'c3bbf53c-8664-4de7-af9b-4752119f0556', 'step_completed', 2, '{\"ecole\":\"sghssh\",\"filiere\":\"sgshs djdj\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:45:49', '2025-09-01 07:45:49'),
('2f20b334-fbe0-4e1c-80cb-ec91c8b74b78', 'bf3413ae-7489-4b53-ac28-2309529dfe9c', 'step_completed', 1, '{\"nom_complet\":\"gdhdjs dhdjdk\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Burkina Faso\",\"password_hash\":\"$2y$12$5uCfoZmn3DvCECA1V1i\\/reJaoPyac6zWneVGnKW4je4B\\/DLwsqIBe\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:57:22', '2025-09-01 07:57:22'),
('309de3bc-8fb1-4579-9ab9-5d3543fd0eec', '2f6d7106-4ec5-434b-98cb-9337654bf977', 'step_completed', 2, '{\"ecole\":\"hdhshd\",\"filiere\":\"cshsjbs\",\"niveau_etude\":\"Master 2\",\"ville\":\"El Jadida\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:19:33', '2025-09-05 23:19:33'),
('32906828-82db-4d43-a27f-6bdcc6a7262a', 'e289004a-5c97-428b-8711-f18970e5ca37', 'step_completed', 1, '{\"nom_complet\":\"sghsjs dkdlld\",\"email\":\"sghsjs@hsj.ghf\",\"telephone\":\"213546789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$lxLsdjc1ekr5RAWzpIQ8QuSmShOrQEAvCJR0zokEXAPzCl41sp0ES\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:25:14', '2025-09-02 09:25:14'),
('34e7b568-ea9c-414e-9925-9426d70bb5a0', '7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 'step_completed', 1, '{\"nom_complet\":\"gshsjs zkks\",\"email\":\"hsjshdh@hdjd.dhd\",\"telephone\":\"15468754864\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$UpbUztYNiOmdI2nynpEkf.HRXPBR0jDr5LXRUjcU.Z1oG3jUx82rS\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:01:15', '2025-09-05 22:01:15'),
('357f24d7-ab86-4714-8c06-336f5e2aabb9', 'f476bf83-f8c4-4079-ba96-4a70a8e96e71', 'step_completed', 2, '{\"ecole\":\"cgghh yjj\",\"filiere\":\"gghh hjjjj\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:35:05', '2025-09-05 21:35:05'),
('39836f95-e434-4439-a70d-08ec8d31425a', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:28:23', '2025-09-05 23:28:23'),
('3a479c07-a58e-4c10-8fdb-ea33a5ab4181', '85079c96-bb47-4e5f-bccd-9df2361dd874', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:25:27', '2025-09-02 10:25:27'),
('3d564445-d653-4519-b2ac-3c225eb45118', '7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:01:27', '2025-09-05 22:01:27'),
('3df17cd0-67e1-423a-9be2-3793c365c89a', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 'code_sent', 4, NULL, '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 08:23:30', '2025-09-02 08:23:30'),
('4204a347-81e0-4567-8706-98d74e21c93b', '64fb5063-d4c2-475c-ab6a-6127be1afa78', 'step_completed', 1, '{\"nom_complet\":\"svbsjs\",\"email\":\"vsjsj@vdh.dhd\",\"telephone\":\"21254643446\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$KdaQ2y1MLapqUUIfLBpt.OkfwrynKHmuL06Aep8c9Lny5iaRMT2\\/C\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:29:51', '2025-09-05 22:29:51'),
('4564fca2-acd4-4a54-be9a-ee80bf7fd61d', '85079c96-bb47-4e5f-bccd-9df2361dd874', 'step_completed', 1, '{\"nom_complet\":\"sxvsbs djsksksk djkd\",\"email\":\"sghsj@sggs.gh\",\"telephone\":\"123456789\",\"nationalite\":\"Burkina Faso\",\"password_hash\":\"$2y$12$DRqPVtfxif3jYeZ5FXp62uHh2.9Gc8.IF73PgP2sqg3jEi9rl0YvC\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:25:11', '2025-09-02 10:25:11'),
('45f2f1b4-3170-4f75-8e96-51364284ed98', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:11:02', '2025-09-05 23:11:02'),
('45fcc9ef-7920-4c93-b52c-834c555cd7c7', 'a068b4f3-1cf8-4974-b16d-7b0cb32213e9', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:43:47', '2025-09-02 11:43:47'),
('47047ac9-3829-46f2-a177-1a7e66a87d95', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:15:36', '2025-09-02 11:15:36'),
('4841a8c7-7c5f-4a51-92ee-f38ff5dfeb27', '81af45a1-07f0-4f52-aa39-6116d1ad216a', 'step_completed', 2, '{\"ecole\":\"fghhhj\",\"filiere\":\"fgghhj\",\"niveau_etude\":\"Master 1\",\"ville\":\"Errachidia\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:44:48', '2025-09-05 22:44:48'),
('4926a9cd-4af5-4316-837e-ec4fdaae1680', 'a9eed21f-6edd-4bcd-94c5-eff032f01d71', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:12:52', '2025-09-02 12:12:52'),
('4b6a1d91-911f-4504-8651-c49a51f9a0b5', '1574db69-a641-469b-b619-5a7d77a815da', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:18:37', '2025-09-05 22:18:37'),
('4ce03fc8-1a7a-4424-a64e-3390dc617c32', 'fb9a870d-a01a-4afe-b94a-6001d99a63fa', 'step_completed', 2, '{\"ecole\":\"ENSAM\",\"filiere\":\"informatique\",\"niveau_etude\":\"Master 2\",\"ville\":\"Errachidia\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 06:51:46', '2025-09-01 06:51:46'),
('4ce7ca8e-280c-4b6d-91e1-37d1e9e48e6b', '9aabb3aa-e915-4a07-8485-c85773adc096', 'step_completed', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"0987654321\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$u5qOac9x6Ksur9mMM4KdG.y0OCo0R3kQHdHDtnpJDMBYdULTlSLOi\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 05:24:22', '2025-09-01 05:24:22'),
('4e67bb38-4824-4324-8566-569c0d10ed4b', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'step_completed', 2, '{\"ecole\":\"wvsvbs\",\"filiere\":\"gshhs\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:25:53', '2025-09-02 11:25:53'),
('4e70abcf-8787-47fb-8028-af9f1c41ac1a', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:27:10', '2025-09-05 23:27:10'),
('4f879824-a25d-4022-8bcb-1f9810ddd01f', '9aabb3aa-e915-4a07-8485-c85773adc096', 'step_completed', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Licence 3\",\"ville\":\"El Jadida\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 05:24:37', '2025-09-01 05:24:37'),
('506b87ad-4474-41c9-aeac-a4b6efd61cd6', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 'step_completed', 3, '{\"competences\":[\"ds hsh\",\"fa hshs\"],\"projects\":[{\"id\":\"cb4175dd-df89-4c79-81e1-be41164b4967\",\"title\":\"shjsjs djsjs\",\"description\":\"gshsh sjsks dkdk\",\"link\":null,\"created_at\":\"2025-09-02T10:22:50+00:00\"}],\"cv_url\":\"cvs\\/cv_1756808569_68b6c57945e83.pdf\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 08:22:50', '2025-09-02 08:22:50'),
('51ce67d7-f74c-4a4e-8856-d274aa32424a', '2f6d7106-4ec5-434b-98cb-9337654bf977', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:19:36', '2025-09-05 23:19:36'),
('52e9965f-6985-4f93-9a82-a0bf888837b8', 'e98c4e2d-9594-4097-8eea-871e464519a0', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:27:51', '2025-09-02 12:27:51'),
('55151862-356a-4057-ab4e-f829133fa7e1', '18fabc8e-7c93-4371-89c0-b203f1eac7c3', 'step_completed', 2, '{\"ecole\":\"sgjsj\",\"filiere\":\"sgsjsjsk\",\"niveau_etude\":\"Master 2\",\"ville\":\"Chefchaouen\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:03:35', '2025-09-01 07:03:35'),
('584ee721-5bee-4625-9f6e-1f34b73f6a5a', 'a068b4f3-1cf8-4974-b16d-7b0cb32213e9', 'step_completed', 1, '{\"nom_complet\":\"zgshjsjs\",\"email\":\"sghsjs@sgsj.djdk\",\"telephone\":\"454312466451\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$MVu4jMhmG.Dwdv0SJo.v0edZutUEwbqKGh4w2BiAVMDLFaC\\/eoACm\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:43:35', '2025-09-02 11:43:35'),
('59a92f6a-7b8b-4d68-949a-fc1ad986cf7f', 'ea75fc5d-5216-4bb0-962c-7898728a0beb', 'step_completed', 3, '{\"competences\":[\"hhbs shsjs sjsk\",\"sghsjs djdkd jdjsk\"],\"projects\":[{\"id\":\"9b32b2c6-cdbc-4b92-b21f-47cec6397bca\",\"title\":\"gshsh sjsks sjsk\",\"description\":\"sgshjs sjsksk sjskns\",\"link\":null,\"created_at\":\"2025-09-01T07:30:19+00:00\"}],\"cv_url\":\"cvs\\/cv_1756711819_68b54b8b56217.pdf\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 05:30:19', '2025-09-01 05:30:19'),
('59dfb69b-5ed5-429f-b1fb-86a1df570e12', 'f08fee38-a6f1-46d3-8959-7f5311cf356b', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:58:47', '2025-09-05 22:58:47'),
('5ceeb23b-f1bc-4565-8eeb-321fb8e31d11', 'a068b4f3-1cf8-4974-b16d-7b0cb32213e9', 'step_completed', 2, '{\"ecole\":\"svhsjsk\",\"filiere\":\"gsjsksk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:43:44', '2025-09-02 11:43:44'),
('5fda4145-a963-43c7-8e2b-e4c2263ee2b2', '7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 'step_completed', 2, '{\"ecole\":\"sghshsb\",\"filiere\":\"ztayhs sjksks\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:01:25', '2025-09-05 22:01:25'),
('5fea85b6-86ca-4344-aaa7-bb95c36a90a6', 'c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', 'step_completed', 2, '{\"ecole\":\"chjkk\",\"filiere\":\"fghjjk\",\"niveau_etude\":\"DUT\",\"ville\":\"El Jadida\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:32:47', '2025-09-02 11:32:47'),
('616274f3-f8b4-405d-b4f4-8a0bab19cf48', '976533e3-a507-4b18-9b13-e756fd67ed2f', 'step_completed', 1, '{\"nom_complet\":\"sgsh djdkkd\",\"email\":\"fahsu@hdk.ffb\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$1UKGuKswbNTVkH1\\/a2wDn.Zw.d14gTzIkFvjBppZk9s4hqr0whmOe\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:55:26', '2025-09-02 10:55:26'),
('62a800a5-417b-4e19-b670-005e689c7424', 'f476bf83-f8c4-4079-ba96-4a70a8e96e71', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:35:07', '2025-09-05 21:35:07'),
('6692bd81-9e47-4ad8-9c31-2d9b8c5410a5', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:16:03', '2025-09-02 11:16:03'),
('679a40c4-54e5-41cf-ae19-5618376c7c7c', '5394c165-7eba-4039-b986-9b73d83d63d8', 'step_completed', 1, '{\"nom_complet\":\"Rztzuz\",\"email\":\"fdhsksh@hdkd.dj\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$pS9WGnuuTtIyYN2OBR6uQOEH2muuRPbrsVAIu6EehBFLR5TmED8jS\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:12:44', '2025-09-02 09:12:44'),
('69762487-bf2e-4e46-87cf-75fc4a005f45', 'e82e4dd2-85a1-4f24-a30e-35f64ca1e207', 'step_completed', 2, '{\"ecole\":\"Etsrs\",\"filiere\":\"shjsjsjs\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Errachidia\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:23:35', '2025-09-01 07:23:35'),
('6c9aa65f-647a-4991-b0da-253924536c39', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true,\"email_sent\":true}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:10:48', '2025-09-05 23:10:48'),
('6f7b3ae0-c84b-45d3-b372-2704816fad05', '5394c165-7eba-4039-b986-9b73d83d63d8', 'step_completed', 2, '{\"ecole\":\"shjsjsjs\",\"filiere\":\"shsjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Dakhla\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:13:41', '2025-09-02 09:13:41'),
('712db871-fe91-4f14-92ae-cf4a75707983', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true,\"email_sent\":true}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:11:28', '2025-09-05 23:11:28'),
('75915619-6e26-4725-b20c-4966b7e5e582', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 2, '{\"ecole\":\"sfhsjsjs\",\"filiere\":\"schsjsn\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:10:04', '2025-09-05 23:10:04'),
('75f74df5-f9b2-45dd-bbed-c0d29ac4c20d', '790b195d-4de9-4df0-a2d3-59868911ecb0', 'step_completed', 1, '{\"nom_complet\":\"Vjsksns dksl\",\"email\":\"shhsgs@djfj.hk\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$zjJSLKkEGG0JUPT3MVrTD.\\/V9FxtC1CqctGzXAQtn.4A0rB7a4vTC\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:10:56', '2025-09-05 21:10:56'),
('779d19ed-e788-4a4e-9baf-0ea92b8b4288', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'step_completed', 1, '{\"nom_complet\":\"chbnnk\",\"email\":\"rimkadelorodg@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$fmN8MTaQPvBpBjOUv2oGIexmNUr3Axe5yxFWz4BAWIBxB6fqNg8IC\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:26:40', '2025-09-05 23:26:40'),
('79849d48-a28b-4eb3-983a-f42b438c0fca', 'bda75f27-d76d-4a4f-b362-7885180d8d6b', 'step_completed', 3, '{\"competences\":[\"wvbwbw\",\"gshshs\",\"gshjs\"],\"cv_url\":\"cvs\\/cv_1756714546_68b55632c244d.pdf\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 06:15:46', '2025-09-01 06:15:46'),
('7b1fe565-145f-42ed-8b66-0a700bea87e5', 'f135ac59-2749-4345-9b15-f11cbac6e240', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:06:40', '2025-09-02 12:06:40'),
('7c6d22ce-4f11-4810-9a5e-ce765421316a', '5a091233-9de7-40fe-a422-759de9567291', 'step_completed', 2, '{\"ecole\":\"chkkkk\",\"filiere\":\"fghjjk\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Errachidia\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:36:56', '2025-09-02 12:36:56'),
('7f0cdf95-e1ad-4b24-8e3a-a95c5f9d84df', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'step_completed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true,\"email_sent\":true}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:27:32', '2025-09-05 23:27:32'),
('8047ab51-1a42-44f6-8be6-815c5b67fb9f', '5a091233-9de7-40fe-a422-759de9567291', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:37:00', '2025-09-02 12:37:00'),
('8b64675c-ecb6-4da0-8fa5-c55767e0a475', '418d80ef-c9c7-4931-9e88-d4e27de84763', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:25:30', '2025-09-05 21:25:30'),
('8d02a98f-a8b5-46b0-8ab9-3f2cdbf4f9e1', 'd614a109-f248-4e07-8e2f-ec1e68972d74', 'step_completed', 2, '{\"ecole\":\"svhsjsks\",\"filiere\":\"vsjsjjsks\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:19:52', '2025-09-02 12:19:52'),
('8d1a9143-7a56-497e-8d41-8c21bf0ca3ba', '18fabc8e-7c93-4371-89c0-b203f1eac7c3', 'step_completed', 1, '{\"nom_complet\":\"shjsjs dkdlld\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$YtOASmoehQUKvL4RF48RR.Nkazu5ol9Xj\\/10XqX4Mvph1evRWdx4i\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:03:26', '2025-09-01 07:03:26'),
('8df95301-c886-4df9-a6c7-aced93c74901', '1715055c-3cae-438d-b65d-5f4c4aed730c', 'step_completed', 1, '{\"nom_complet\":\"sghsjs dhdjdk\",\"email\":\"ffshsjs@gdj.dh\",\"telephone\":\"2354647846\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$L5gP3ATUEWhu7byNYCgNdOHrSvrMdT212wxtyY110H9WCQbX40QsG\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:59:52', '2025-09-02 10:59:52'),
('8ee576fc-4d64-420d-9831-7ed89e134139', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true,\"email_sent\":true}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:11:02', '2025-09-05 23:11:02'),
('91040483-2ca2-43d0-b0eb-8544ce632db7', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'step_completed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true,\"email_sent\":true}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:27:10', '2025-09-05 23:27:10'),
('9345f422-6637-4460-b881-f123f8574bb6', '85079c96-bb47-4e5f-bccd-9df2361dd874', 'step_completed', 2, '{\"ecole\":\"shsjjs zjks\",\"filiere\":\"sgjsjdkd\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Dakhla\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:25:24', '2025-09-02 10:25:24'),
('97221311-cf73-45b5-8d4f-76aaa5d171ba', '6cdb793c-96e8-4aae-8382-a140824f64bb', 'step_completed', 1, '{\"nom_complet\":\"ghjj\",\"email\":\"cghjkk@ty.hj\",\"telephone\":\"222565662\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$FSPcghP4WaHpY0GeEoNsIO2m0vuvVe0uCj6FPi7XaXWEd6BWj8ysO\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:52:32', '2025-09-05 22:52:32'),
('9832d54f-f54d-4b28-9873-bbaf062efba2', 'f476bf83-f8c4-4079-ba96-4a70a8e96e71', 'step_completed', 1, '{\"nom_complet\":\"dfghhj thhj\",\"email\":\"fghjhf@xcg.hj\",\"telephone\":\"5224455785\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$lLAVjOIunG1SHIdBttyiZOmY0L2sFxEHpHxKgS0eTDR\\/0AfqGXXg2\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:34:52', '2025-09-05 21:34:52'),
('9988bc42-5bc9-4a9b-a14d-601f8faa5be1', '64fb5063-d4c2-475c-ab6a-6127be1afa78', 'step_completed', 2, '{\"ecole\":\"cvbb\",\"filiere\":\"ghhhh\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Guelmim\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:30:00', '2025-09-05 22:30:00'),
('9e425a4b-fa2f-4ce4-a783-cdc8600f05cc', 'c3bbf53c-8664-4de7-af9b-4752119f0556', 'step_completed', 1, '{\"nom_complet\":\"sgshsj djdj\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$ZtUrOOC5egtP9nUA82Fal.pzM7O5zJJjP0HRy6ZVTcW8WYG3S2tTK\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:45:39', '2025-09-01 07:45:39'),
('9e90b735-17b8-43f3-9dee-2a75fa2aa50c', '9aabb3aa-e915-4a07-8485-c85773adc096', 'step_completed', 3, '{\"competences\":[\"gshsh\",\"sgshjs zhjsk\",\"gshsh shjs shjs\"],\"projects\":[{\"id\":\"69c7601d-d9ab-440f-9ca7-714dc129ffdb\",\"title\":\"gshjs\",\"description\":\"sghsj sjsjjs shjs shsjjs\",\"link\":null,\"created_at\":\"2025-09-01T07:25:20+00:00\"}],\"cv_url\":\"cvs\\/cv_1756711520_68b54a6002efd.pdf\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 05:25:20', '2025-09-01 05:25:20'),
('9f6a6ab0-f0ca-4f62-8c04-384ef194295a', '2f6d7106-4ec5-434b-98cb-9337654bf977', 'step_completed', 1, '{\"nom_complet\":\"wvjsjsksk\",\"email\":\"rimkadelorodg@gmail.com\",\"telephone\":\"123154645\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$aUm6eAVeE0WP8NVKJ6BSbO0KjjYesl1BrtxsOaFNhVSuWPKuTEhq2\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:19:24', '2025-09-05 23:19:24'),
('9fa6af9c-a56c-4508-93e8-1dcecfaa6859', 'd614a109-f248-4e07-8e2f-ec1e68972d74', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:19:55', '2025-09-02 12:19:55'),
('9ffde1b5-7a08-4bba-af45-5d43e626a0f2', 'ea75fc5d-5216-4bb0-962c-7898728a0beb', 'step_completed', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Master 1\",\"ville\":\"Guelmim\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 05:29:47', '2025-09-01 05:29:47'),
('a26cb90f-0ab0-47ca-8997-4fed1ea6fddc', 'bda75f27-d76d-4a4f-b362-7885180d8d6b', 'step_completed', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$rJE\\/4lY8lGOfY1jlD7G0OOnqaTjmBsry8BanuWnjdm7H.YMgvnRNm\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 06:15:00', '2025-09-01 06:15:00'),
('a34a8591-bcea-422f-8f41-31419322dad3', '5394c165-7eba-4039-b986-9b73d83d63d8', 'step_completed', 1, '{\"nom_complet\":\"Rztzuz\",\"email\":\"fdhsksh@hdkd.dj\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"session_token\":\"UJ4kj93JHTOewsxKanCV21x6V2MKqcrj4sFPOBlhC9u90W4nfGnUBsoZ6koRiAol\",\"password_hash\":\"$2y$12$hvQDN6RS7SP5S\\/aD4DH18uZIkAmm3j06H2GVX.cy7k.0JCorLVm6G\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:13:09', '2025-09-02 09:13:09'),
('a3c6c232-0452-46d9-a7ef-22d0f3bb0411', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 'step_completed', 1, '{\"nom_complet\":\"Bambio\",\"email\":\"bambiodoubalogerome73@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$DdNU3hXGLd\\/zJ6vW1yWyLeCYLSb7\\/w.Hqe6aVQH\\/s\\/AabbzuUj4ZO\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 08:22:05', '2025-09-02 08:22:05'),
('a3f8f100-e1c1-438b-94ab-2ac613a60a50', 'fb9a870d-a01a-4afe-b94a-6001d99a63fa', 'step_completed', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$GTEq9WbudCUK.B52zT9b1OKuv2gdjlILrfyseNJ6PqKo7QYYJANwW\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 06:51:32', '2025-09-01 06:51:32'),
('a5aec36a-b23d-4f4e-a209-bf6990e5d6ba', 'e82e4dd2-85a1-4f24-a30e-35f64ca1e207', 'step_completed', 1, '{\"nom_complet\":\"svbsnwn sbsjks snsk\'s\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Burundi\",\"password_hash\":\"$2y$12$MFZ\\/Ybz9V8V.0aPXENGRTu6\\/7yG7BnATiEB4vcBjRIZ9gSH.Rdtvi\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:22:32', '2025-09-01 07:22:32'),
('a6010b88-ecd9-46c2-afd2-2c1c4ef72394', 'f08fee38-a6f1-46d3-8959-7f5311cf356b', 'step_completed', 2, '{\"ecole\":\"ccghh\",\"filiere\":\"fghhhjh\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:58:44', '2025-09-05 22:58:44'),
('a700faf8-9327-4ac3-b86a-01d946735b96', 'c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', 'step_completed', 1, '{\"nom_complet\":\"dghjj\",\"email\":\"dfgjjk@xcg.hj\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$9n1MOB0Ly3njDHfZzuDFWubpVUFNAC3wGA0Vf8Yjsg1omXYT0xsRa\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:32:38', '2025-09-02 11:32:38'),
('aeac6cbf-7110-4ec5-8a6a-fc790a429eb7', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 'step_completed', 1, '{\"nom_complet\":\"sgsyzjzj\",\"email\":\"sghsjs@sgsj.dhd\",\"telephone\":\"2134684846\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$JxTMDV\\/jq4BMurIa0HACzeCk7Mtwz4X\\/.fVu4.EFPcwQrd1nfibTy\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:15:06', '2025-09-02 11:15:06'),
('aff3bd67-2080-4212-8560-d4f32bb4964b', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:10:36', '2025-09-05 23:10:36'),
('b2aefc19-d5f9-4332-ab9c-cd0b801ed141', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'step_completed', 1, '{\"nom_complet\":\"reydyeueu\",\"email\":\"zcshudud@dvhd.bj\",\"telephone\":\"5464612428\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$VmsbQogdsgs6N8JTbXIIhOXN9d2TZ4E30ZqhxCqKNHVpn7KYL9xh2\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:25:43', '2025-09-02 11:25:43'),
('b2fd18fd-af22-468c-8c9d-f4aebdebfab8', '418d80ef-c9c7-4931-9e88-d4e27de84763', 'step_completed', 1, '{\"nom_complet\":\"dthj\",\"email\":\"fghjkk@ffg.ghj\",\"telephone\":\"123456789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$NKurxQp6aJ49oPc7YBPnaucNP5h6Q8mKCzwVZgsjiqsGRBwj.ASvi\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:25:10', '2025-09-05 21:25:10'),
('b5b465dc-38ac-4d7d-96a6-38733965da60', '5394c165-7eba-4039-b986-9b73d83d63d8', 'step_completed', 2, '{\"ecole\":\"shjsjsjs\",\"filiere\":\"shsjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Dakhla\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 09:12:56', '2025-09-02 09:12:56'),
('ba0c0bbf-d7a8-44c2-8e9f-dd8fc29111f8', '1574db69-a641-469b-b619-5a7d77a815da', 'step_completed', 2, '{\"ecole\":\"hhhh\",\"filiere\":\"hdhsjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:18:34', '2025-09-05 22:18:34'),
('ba25c9b1-fa34-4b58-baee-fd7870f02410', 'bda75f27-d76d-4a4f-b362-7885180d8d6b', 'step_completed', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 06:15:13', '2025-09-01 06:15:13'),
('bb3958bf-0759-4e4f-82bf-91ea77bcfa45', 'f135ac59-2749-4345-9b15-f11cbac6e240', 'step_completed', 2, '{\"ecole\":\"wvwbnw\",\"filiere\":\"shsjsjs djdjd\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Dakhla\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:06:37', '2025-09-02 12:06:37'),
('bbbf9a56-609e-470f-a3b0-4b4628b834a8', '5a091233-9de7-40fe-a422-759de9567291', 'step_completed', 1, '{\"nom_complet\":\"xghjk\",\"email\":\"fhjj@fgh.gh\",\"telephone\":\"52366666665\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$eTj4sKR8OEz7Qw646ynL2eb06rlJSGlzIXxKIcv6KPZbt2p5lIWEe\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:36:45', '2025-09-02 12:36:45'),
('bce9b7eb-4c6f-4fc2-9048-cc2845e7d765', '64fb5063-d4c2-475c-ab6a-6127be1afa78', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:30:03', '2025-09-05 22:30:03'),
('be949dc0-5e80-42df-9297-d5fba18d3284', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'step_completed', 1, '{\"nom_complet\":\"reydyeueu\",\"email\":\"zcshudud@dvhd.bj\",\"telephone\":\"5464612428\",\"nationalite\":\"Comores\",\"session_token\":\"YjQ39CKJehQJReELDncJEi9KtSOTnUe9W7OM48xrMgPrV235cRnZdOwSBMFwDGJx\",\"password_hash\":\"$2y$12$GrynVR5EPZDFvERonV7kFeGRrtgxoYStxznI9NuHjT0tMOiSb\\/W1C\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:26:42', '2025-09-02 11:26:42'),
('c026c1c8-888c-417f-a3ce-4065eb1333b8', 'e98c4e2d-9594-4097-8eea-871e464519a0', 'step_completed', 1, '{\"nom_complet\":\"rtyyyu\",\"email\":\"fggh@fgh.jj\",\"telephone\":\"455558885\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$EUgu3PfXLXiLrE382LQe2enm4MvjzQj21eIsxp0xVpHvUXMNaQ2Ey\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:27:08', '2025-09-02 12:27:08'),
('c156fb46-485e-47c8-a034-8807abd15c0d', '1f79f35a-fcf1-450f-93fb-326185f8c976', 'step_completed', 2, '{\"ecole\":\"sghsjs\",\"filiere\":\"shsjjs\",\"niveau_etude\":\"Master 2\",\"ville\":\"F\\u00e8s\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:30:57', '2025-09-01 07:30:57'),
('c217d6dc-fd96-415e-8e99-11158fbdf0f2', 'f135ac59-2749-4345-9b15-f11cbac6e240', 'step_completed', 1, '{\"nom_complet\":\"hsjsj\",\"email\":\"qgsjsj@gdjd.fhd\",\"telephone\":\"5464849484978\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$DZOWocZpicc.PdPOaOeBcu94OyzqmWd2IV\\/2yiJsdQtd49tLPEZam\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:06:27', '2025-09-02 12:06:27'),
('c44ae3ae-fb08-43d8-9fae-5563cd317533', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:26:51', '2025-09-05 23:26:51'),
('c515dd43-d82f-4c03-9a19-16f5eb5d9315', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 'step_completed', 2, '{\"ecole\":\"gshsjs\",\"filiere\":\"svjsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:15:33', '2025-09-02 11:15:33'),
('c62a746c-ce8d-4d71-a064-ac2a9f623db7', '2e567776-a92b-4946-bad3-ad59c2f28825', 'step_completed', 1, '{\"nom_complet\":\"sxvsbs djsksksk djkd\",\"email\":\"sghsj@sggs.gh\",\"telephone\":\"123456789\",\"nationalite\":\"Burkina Faso\",\"password_hash\":\"$2y$12$4lZDyIRkvdwEeJmmAFFw7OknxE7E8MVLdadLf0F9DXjZqYqfKLUXi\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:24:43', '2025-09-02 10:24:43'),
('c79b86c2-09c2-4545-aa4a-be29b457437f', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:25:57', '2025-09-02 11:25:57'),
('ca547047-c160-4360-942d-22501bcdec75', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:27:32', '2025-09-05 23:27:32'),
('caefa3d4-2a99-466f-9e21-42c75b06e8f0', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 'step_completed', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 08:22:23', '2025-09-02 08:22:23'),
('cca03ff3-8a69-45d7-a1d1-dcca915d2534', 'd614a109-f248-4e07-8e2f-ec1e68972d74', 'step_completed', 1, '{\"nom_complet\":\"vdjsjs\",\"email\":\"hshs@gshs.dhdj\",\"telephone\":\"64345494894\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$xM\\/LyX8u1CTjRDu514yqL.YWPVitdrRJQYz.nFOEMv8uMH7HK6u4S\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 12:19:44', '2025-09-02 12:19:44'),
('d049264c-9a8d-4ce8-8187-e5e164d9cbe1', 'bf3413ae-7489-4b53-ac28-2309529dfe9c', 'step_completed', 3, '{\"competences\":[\"shbsbw\"],\"projects\":[{\"id\":\"2c28507f-36ea-415c-aaac-a2640f3bc9e7\",\"title\":\"shsjjs\",\"description\":\"shsjs sjsjjs djdkdk\",\"link\":null,\"created_at\":\"2025-09-01T09:57:53+00:00\"}],\"cv_url\":\"cvs\\/cv_1756720673_68b56e21c15a5.pdf\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:57:53', '2025-09-01 07:57:53'),
('d0c5e137-8f94-47cb-83a3-7ba7e4e28106', '6cdb793c-96e8-4aae-8382-a140824f64bb', 'step_completed', 2, '{\"ecole\":\"vbbj\",\"filiere\":\"bjjj\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:52:42', '2025-09-05 22:52:42'),
('d3059b92-12cb-4e22-873c-032f34deed34', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:10:07', '2025-09-05 23:10:07'),
('d57a057c-45f7-40e2-9f18-f62b392a2903', 'e82e4dd2-85a1-4f24-a30e-35f64ca1e207', 'step_completed', 2, '{\"ecole\":\"Etsrs\",\"filiere\":\"shjsjsjs\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Errachidia\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:22:43', '2025-09-01 07:22:43'),
('d7f5742e-fc04-42e1-bf6b-f873f09f2e01', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:11:28', '2025-09-05 23:11:28'),
('dd10c886-950e-4043-b7e6-70ef6df11415', '1715055c-3cae-438d-b65d-5f4c4aed730c', 'step_completed', 2, '{\"ecole\":\"shjsjs\",\"filiere\":\"ztsus sjsk\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:00:15', '2025-09-02 11:00:15'),
('dd6ef67f-d520-455e-8e91-5b901f1eb31f', '976533e3-a507-4b18-9b13-e756fd67ed2f', 'step_completed', 2, '{\"ecole\":\"sghsjs\",\"filiere\":\"sgzysu sjdjd\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 10:55:38', '2025-09-02 10:55:38'),
('e1d56de6-cbd3-4707-892f-1a4590f90011', '70a80207-3800-47cb-8b0b-2cef290ae030', 'step_completed', 1, '{\"nom_complet\":\"Vjsksns dksl\",\"email\":\"shhsgs@djfj.hk\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$rWMiVwQ2nd\\/\\/ytCW0qoJo.4QlCemP0va1HOl5xga6bFP9\\/umLbGRa\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:11:02', '2025-09-05 21:11:02'),
('e338b10f-c472-42fd-98d4-ff05d425bab9', '1574db69-a641-469b-b619-5a7d77a815da', 'step_completed', 1, '{\"nom_complet\":\"gdjskksks\",\"email\":\"sjjsjsk@vdjd.dhd\",\"telephone\":\"46644654346\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$fcXV\\/6wpXQMHx\\/o\\/tZXvQuApnV2IAvRhqvG\\/.na3T805V82nod8pa\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:18:23', '2025-09-05 22:18:23'),
('e3ae1a4f-525c-4e16-803c-6c2429bdc63d', 'c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:32:50', '2025-09-02 11:32:50'),
('e3c6b074-9201-4d37-9c58-d645aea39c88', '9530fcc7-3d10-42b6-82c3-9e0384376364', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:08:34', '2025-09-02 11:08:34'),
('e54155e8-d514-46c1-8fc5-5e9280a9d265', '9530fcc7-3d10-42b6-82c3-9e0384376364', 'step_completed', 2, '{\"ecole\":\"whshjs\",\"filiere\":\"shjs sjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:08:29', '2025-09-02 11:08:29'),
('e7602120-9ae6-4892-b5e9-c63b7e07895b', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'code_sent', 4, NULL, '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:10:48', '2025-09-05 23:10:48'),
('e8d87458-6476-43c4-91cc-7721facbe7c2', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'step_completed', 3, '[]', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:26:48', '2025-09-02 11:26:48'),
('e8e7fbe5-b773-499f-9e30-3a5735502cac', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 'step_completed', 2, '{\"ecole\":\"rty\",\"filiere\":\"dghu\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 23:26:49', '2025-09-05 23:26:49'),
('e9297bc9-05e0-441b-9532-7be6d7b4c1a9', '3d6a52fb-6e97-415c-93a2-1fd1902d6439', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:21:23', '2025-09-05 21:21:23'),
('e9a7a39b-01df-4383-85a8-626bfdbbbfc5', '3d6a52fb-6e97-415c-93a2-1fd1902d6439', 'step_completed', 2, '{\"ecole\":\"dghjj\",\"filiere\":\"ftyyuu hhj\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:21:20', '2025-09-05 21:21:20'),
('f3fdc948-51b4-473b-aed6-6e66fd57ef89', '11106542-eab1-4a8b-aee9-9031a401ee96', 'step_completed', 1, '{\"nom_complet\":\"Vjsksns dksl\",\"email\":\"shhsgs@djfj.hk\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$xXz\\/JTZsbxVnwYy6rEYUsOsCvQp2wtJ7L2jxdE9RXEGT6vLpAq6s2\"}', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 21:10:58', '2025-09-05 21:10:58'),
('f467fc6b-91a6-4480-aad1-4100658fe3bd', '1f79f35a-fcf1-450f-93fb-326185f8c976', 'step_completed', 1, '{\"nom_complet\":\"shjsjs ds sns\'\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$PaWJP1UPv\\/WJGTkrDcR\\/UeSyIswvuIN3Y3qTTHExoa06oVIlJB93C\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-01 07:30:44', '2025-09-01 07:30:44'),
('f4e9d08e-b393-44d8-a53d-45ee01d30137', '81af45a1-07f0-4f52-aa39-6116d1ad216a', 'step_completed', 3, '[]', '172.26.153.101', 'Dart/3.8 (dart:io)', '2025-09-05 22:44:50', '2025-09-05 22:44:50'),
('f8dd972a-9fbf-4188-9f64-b934e300c503', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 'step_completed', 2, '{\"ecole\":\"gshsjs\",\"filiere\":\"svjsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '10.25.136.5', 'Dart/3.8 (dart:io)', '2025-09-02 11:16:01', '2025-09-02 11:16:01');

-- --------------------------------------------------------

--
-- Structure de la table `registration_processes`
--

CREATE TABLE `registration_processes` (
  `id` char(36) NOT NULL,
  `session_token` varchar(64) NOT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `current_step` tinyint(4) NOT NULL DEFAULT 1,
  `total_steps` tinyint(4) NOT NULL DEFAULT 5,
  `status` enum('in_progress','completed','abandoned','expired') NOT NULL DEFAULT 'in_progress',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `registration_processes`
--

INSERT INTO `registration_processes` (`id`, `session_token`, `user_email`, `current_step`, `total_steps`, `status`, `metadata`, `expires_at`, `created_at`, `updated_at`) VALUES
('11106542-eab1-4a8b-aee9-9031a401ee96', 'xQvdEfuJfI14QORsAdWL37cKlvXDxBt2U54ATuHCx0DwUx0lPX1I5q0XyM7QtQFx', 'shhsgs@djfj.hk', 1, 5, 'in_progress', NULL, '2025-09-05 23:10:58', '2025-09-05 21:10:58', '2025-09-05 21:10:58'),
('1574db69-a641-469b-b619-5a7d77a815da', 'S5AdGy08UffXrVhDdXPsOnssAi9n6H7ghpnDSUM8fdBwzO2q1hJ7p9CfhX8HWOrj', 'sjjsjsk@vdjd.dhd', 3, 5, 'in_progress', NULL, '2025-09-06 00:18:37', '2025-09-05 22:18:23', '2025-09-05 22:18:37'),
('1715055c-3cae-438d-b65d-5f4c4aed730c', 'ka2vvfDeeOW3hk17ZB2tkpQB0SJX2RQL98qPo2y7iuFoGBp9SnQ6vaKXmwjhlQsC', 'ffshsjs@gdj.dh', 3, 5, 'in_progress', NULL, '2025-09-02 13:00:18', '2025-09-02 10:59:51', '2025-09-02 11:00:18'),
('18fabc8e-7c93-4371-89c0-b203f1eac7c3', 'VGhmXxKiYxZNP4kRanXnUXxIVL1yjlhCjAmtAu6qwoIBAPZARVQZGlm9ABvt6lxV', 'ravaosolomarguerite66@gmail.com', 2, 5, 'in_progress', NULL, '2025-09-01 09:03:35', '2025-09-01 07:03:26', '2025-09-01 07:03:35'),
('1f79f35a-fcf1-450f-93fb-326185f8c976', 'HdAAk4ijDTSY8xBnwPNRPfJb3VfP0y7qXqnxVZqVTDm107O0WfwMlNh8mtLvfrOf', 'ravaosolomarguerite66@gmail.com', 2, 5, 'in_progress', NULL, '2025-09-01 09:30:57', '2025-09-01 07:30:44', '2025-09-01 07:30:57'),
('20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 'YjQ39CKJehQJReELDncJEi9KtSOTnUe9W7OM48xrMgPrV235cRnZdOwSBMFwDGJx', 'zcshudud@dvhd.bj', 3, 5, 'in_progress', NULL, '2025-09-03 11:26:48', '2025-09-02 11:25:43', '2025-09-02 11:26:48'),
('2e567776-a92b-4946-bad3-ad59c2f28825', '9QMzIvO375s550Jsz5UbFNkFZ3y7eBZ1dS6pZP7JA3zAvpPHixWlRXLFkDl0nhTG', 'sghsj@sggs.gh', 1, 5, 'in_progress', NULL, '2025-09-02 12:24:42', '2025-09-02 10:24:42', '2025-09-02 10:24:42'),
('2f6d7106-4ec5-434b-98cb-9337654bf977', 'K8qiw3RIGxbkPPws7yNLSIed3ec0qSpKUkUqiHGbvL8mYNKluLBX1HNXHqFX7jN3', 'rimkadelorodg@gmail.com', 3, 5, 'in_progress', NULL, '2025-09-06 01:19:36', '2025-09-05 23:19:23', '2025-09-05 23:19:36'),
('3d6a52fb-6e97-415c-93a2-1fd1902d6439', 'Co6BuOu1xbQr5v7uon2n2HNxqar4sntkuylV8ZqAANbkOgRtiuYgsEOu0EflzoVy', 'sgsjjsj@vjdkd.djdj', 3, 5, 'in_progress', NULL, '2025-09-05 23:21:23', '2025-09-05 21:19:46', '2025-09-05 21:21:23'),
('418d80ef-c9c7-4931-9e88-d4e27de84763', 'qX7N8ReqwyBdpZfPTFrfrgLIpyPgbcC6MPNP0UTeQU8lzoBcw65g7kUL2QImKHzW', 'fghjkk@ffg.ghj', 3, 5, 'in_progress', NULL, '2025-09-05 23:25:30', '2025-09-05 21:25:10', '2025-09-05 21:25:30'),
('4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 'n0UkXA7iDGvVbujiwcEsuWrsoLJYdFzDsE1SXiBozeOy5qKALuu9s9oJJU4Qu67h', 'bambiodoubalogerome73@gmail.com', 4, 5, 'in_progress', '{\"verification_code\":\"190958\",\"verification_expires_at\":\"2025-09-02T10:33:22+00:00\",\"verification_attempts\":0,\"code_sent_at\":\"2025-09-02T10:23:22+00:00\"}', '2025-09-02 10:23:22', '2025-09-02 08:22:05', '2025-09-02 08:23:22'),
('5394c165-7eba-4039-b986-9b73d83d63d8', 'UJ4kj93JHTOewsxKanCV21x6V2MKqcrj4sFPOBlhC9u90W4nfGnUBsoZ6koRiAol', 'fdhsksh@hdkd.dj', 3, 5, 'in_progress', NULL, '2025-09-02 11:13:44', '2025-09-02 09:12:44', '2025-09-02 09:13:44'),
('5a091233-9de7-40fe-a422-759de9567291', 'pn3GlE9JODRkcXnUqgG4tZjcCcDN98Cl6sjMGAzMLMe5Qv8fSolb3Gqox3CsnPR8', 'fhjj@fgh.gh', 3, 5, 'in_progress', NULL, '2025-09-02 14:37:00', '2025-09-02 12:36:45', '2025-09-02 12:37:00'),
('64fb5063-d4c2-475c-ab6a-6127be1afa78', 'MmeBX0YXIbhDxdXVLr2Q696JL37t6xuDpzBmWtzSm7rLNCQOajx7HKzi9iK2J0lu', 'vsjsj@vdh.dhd', 3, 5, 'in_progress', NULL, '2025-09-06 00:30:03', '2025-09-05 22:29:51', '2025-09-05 22:30:03'),
('6cdb793c-96e8-4aae-8382-a140824f64bb', 'XqqHFVC1GpWwUDwX8SD7n4Nqzlkexiv8TXr7OwBaB1CYwCF6fIXfbKS8NZlQJqrl', 'cghjkk@ty.hj', 3, 5, 'in_progress', NULL, '2025-09-06 00:52:45', '2025-09-05 22:52:32', '2025-09-05 22:52:45'),
('70a80207-3800-47cb-8b0b-2cef290ae030', 'RNCQjIBnoJIGlcVCgzu4wECtIf0R5nrjkXI9aqxuOFyvObVo4mLYJiJxU4tPBNwB', 'shhsgs@djfj.hk', 3, 5, 'in_progress', NULL, '2025-09-05 23:11:23', '2025-09-05 21:11:02', '2025-09-05 21:11:23'),
('790b195d-4de9-4df0-a2d3-59868911ecb0', 'ncdjOaX8lknu6o3luI79VzNOKFtVbDbbQ65EWpvBhTTJCMDUQA3JyZjTclLkcvzf', 'shhsgs@djfj.hk', 1, 5, 'in_progress', NULL, '2025-09-05 23:10:56', '2025-09-05 21:10:56', '2025-09-05 21:10:56'),
('7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 'qwCQhKlRf6eOJXj6J6DNX1CkAYCclechNc1G3O0tV5lYS8Xs84dxBGTkm5HxySvL', 'hsjshdh@hdjd.dhd', 3, 5, 'in_progress', NULL, '2025-09-06 00:01:27', '2025-09-05 22:01:15', '2025-09-05 22:01:27'),
('81af45a1-07f0-4f52-aa39-6116d1ad216a', 'NmUM4BYrTClMOm1NGzpWMG1uGCw7AEnVtn5JciHwznSbtp9mCvdzSX69yActthVC', 'fgghjj@fgh.bh', 3, 5, 'in_progress', NULL, '2025-09-06 00:44:50', '2025-09-05 22:44:37', '2025-09-05 22:44:50'),
('85079c96-bb47-4e5f-bccd-9df2361dd874', '2fMNhNeiUmi2hrdlPj1L7C20cMV47VGtBgvFylXpCW3BcjI9RjAlYZAZnCeuonwm', 'sghsj@sggs.gh', 3, 5, 'in_progress', NULL, '2025-09-02 12:25:27', '2025-09-02 10:25:11', '2025-09-02 10:25:27'),
('9530fcc7-3d10-42b6-82c3-9e0384376364', 'oN1oSSzTiJMlYeDuyZuVr0YcHVFoAyaLUH03GxXiuHSectKwn3ID6RbyDpHUm2k7', 'fshs@hdj.hj', 3, 5, 'in_progress', NULL, '2025-09-02 13:08:34', '2025-09-02 11:08:01', '2025-09-02 11:08:34'),
('976533e3-a507-4b18-9b13-e756fd67ed2f', '4UBXl1zFjAEGDyEdnJhtq5y0nwd9X9yYgind6bFl7j8pX2QbRdjOPRgE5qOtwLWU', 'fahsu@hdk.ffb', 3, 5, 'in_progress', NULL, '2025-09-02 12:55:41', '2025-09-02 10:55:26', '2025-09-02 10:55:41'),
('9a3d0f02-dfd3-4857-b084-b065164c7bed', 'gZ4UN13set53UaQfkkD5LV39FiSWvhYxWQAMW6ttt8Yjcm162LAokLS5gHLSM7sj', 'rimkadelorodg@gmail.com', 4, 5, 'in_progress', '{\"verification_code\":\"392291\",\"verification_expires_at\":\"2025-09-06T01:38:15+00:00\",\"verification_attempts\":0,\"code_sent_at\":\"2025-09-06T01:28:15+00:00\"}', '2025-09-06 23:31:03', '2025-09-05 23:26:40', '2025-09-05 23:31:03'),
('9aabb3aa-e915-4a07-8485-c85773adc096', 'VbuIKb1T8Yt1vKk5QwH87FV5BOuzMGFipfrjDJvLZtKnAWcbgMyTNy5QhBSMhrq7', 'ravaosolomarguerite66@gmail.com', 3, 5, 'in_progress', NULL, '2025-09-01 07:25:20', '2025-09-01 05:24:22', '2025-09-01 05:25:20'),
('a068b4f3-1cf8-4974-b16d-7b0cb32213e9', '64bJOI1q1PlVT71aBR3uO93xe0X9RQLEbaQrUxOe6jzMVEM28VqTpfDGAoZVbocY', 'sghsjs@sgsj.djdk', 3, 5, 'in_progress', NULL, '2025-09-02 13:43:47', '2025-09-02 11:43:35', '2025-09-02 11:43:47'),
('a9eed21f-6edd-4bcd-94c5-eff032f01d71', 'aqDb6GglOWs7tQ2OrRkAAcAUYTr7wMih6sWsoHGvgWv00wZzOQhKuO7eT35p61LH', 'sghsjs@sgsj.djdk', 3, 5, 'in_progress', NULL, '2025-09-02 14:12:52', '2025-09-02 12:12:40', '2025-09-02 12:12:52'),
('bda75f27-d76d-4a4f-b362-7885180d8d6b', 'QwLqYAOT0VCp3j2ahYFi1rryYZ1ryropsuZjXc4Ii9fPAFLZYbtOfBOg5LjYAEAv', 'ravaosolomarguerite66@gmail.com', 3, 5, 'in_progress', NULL, '2025-09-01 08:15:46', '2025-09-01 06:15:00', '2025-09-01 06:15:46'),
('bf3413ae-7489-4b53-ac28-2309529dfe9c', 'muA1TsUcIhMzc5aO6ZlQFJlzyrHhO7fqM1wzFkJi3sGL362Kkp1XMxsnm6FMf9IY', 'ravaosolomarguerite66@gmail.com', 3, 5, 'in_progress', NULL, '2025-09-01 09:57:53', '2025-09-01 07:57:21', '2025-09-01 07:57:53'),
('c3bbf53c-8664-4de7-af9b-4752119f0556', 'Ys89u7nN6dlpHPFfhgQ8sspxsjeW9GNWlgqyp8bHyUvSqoQCQdA6eYezQXFwFk24', 'ravaosolomarguerite66@gmail.com', 2, 5, 'in_progress', NULL, '2025-09-01 09:45:49', '2025-09-01 07:45:39', '2025-09-01 07:45:49'),
('c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', '8L9wIg9jtNQBvUD20GIvZyLZ8kz9qbuvXznfHfxZ1FV7SiB5Aks5sNwTJ72AzKwS', 'dfgjjk@xcg.hj', 3, 5, 'in_progress', NULL, '2025-09-02 13:32:50', '2025-09-02 11:32:38', '2025-09-02 11:32:50'),
('cb06a9ec-98e4-420f-ba5d-57f126a9747c', 'plTKA9hOQE1WhPbru8CFlVF9B8YVOptVwEtKkLBRmNUgkOuMMarh4vbmH3rhuL84', 'rimkadelorodg@gmail.com', 4, 5, 'in_progress', '{\"verification_code\":\"997087\",\"verification_expires_at\":\"2025-09-06T01:21:15+00:00\",\"verification_attempts\":0,\"code_sent_at\":\"2025-09-06T01:11:15+00:00\"}', '2025-09-06 01:11:15', '2025-09-05 23:09:53', '2025-09-05 23:11:15'),
('d34fbd88-86f7-42e3-81c4-acd142b687c4', 'oZx9VwsDirmiun1f6vANlNvGDBPg7Q0WCdqJ85W1YTCsmVTsqqMdMqned69zRWfs', 'sghsjs@sgsj.dhd', 3, 5, 'in_progress', NULL, '2025-09-03 11:17:35', '2025-09-02 11:15:06', '2025-09-02 11:17:35'),
('d614a109-f248-4e07-8e2f-ec1e68972d74', 'L5b9seQYOl3T9nZt0xKzHzn8iGdjh44utMQYAE9hM7AlnqSXJXnXUj5S7kdVcBo2', 'hshs@gshs.dhdj', 3, 5, 'in_progress', NULL, '2025-09-02 14:19:55', '2025-09-02 12:19:43', '2025-09-02 12:19:55'),
('e289004a-5c97-428b-8711-f18970e5ca37', 'NIwP1OfDuZFozeoDw1MKJIUQQW5z6lAcIxlmD1dT7Nz6kd2sOPzamOOQAxXIXKU4', 'sghsjs@hsj.ghf', 3, 5, 'in_progress', NULL, '2025-09-02 11:25:37', '2025-09-02 09:25:14', '2025-09-02 09:25:37'),
('e2b37756-5a36-4412-ab35-06fd863cdcdc', 'JHUreyNeaAwV3JiP9Vx7bcDcnAiYZdp7QP7Y5rqfYqfyVSpAWS8vulQeuGSymI8R', 'ravaosolomarguerite66@gmail.com', 2, 5, 'in_progress', NULL, '2025-09-01 09:37:07', '2025-09-01 07:36:57', '2025-09-01 07:37:07'),
('e82e4dd2-85a1-4f24-a30e-35f64ca1e207', 'cgLxAUDCVXqOLvBpqTbB61P2p5AKgMY0NXV2IL5nLAWznUYWWihWXKH1opPJQKlZ', 'ravaosolomarguerite66@gmail.com', 2, 5, 'in_progress', NULL, '2025-09-02 07:23:35', '2025-09-01 07:22:32', '2025-09-01 07:23:35'),
('e98c4e2d-9594-4097-8eea-871e464519a0', 'yEoRKNjf3BT6qm6XOP5DGT7VHngM3Cr91l0eaUhNWWwFLBptduOaPtWHijda66vQ', 'fggh@fgh.jj', 3, 5, 'in_progress', NULL, '2025-09-02 14:27:51', '2025-09-02 12:27:08', '2025-09-02 12:27:51'),
('ea75fc5d-5216-4bb0-962c-7898728a0beb', 'JLAf4sbbHyyeHnpgWbelUyAxmiboCQAD2ziPrUSER7zq91XuoBQSwNaFroIMmd4B', 'ravaosolomarguerite66@gmail.com', 3, 5, 'in_progress', NULL, '2025-09-01 07:30:19', '2025-09-01 05:29:36', '2025-09-01 05:30:19'),
('f08fee38-a6f1-46d3-8959-7f5311cf356b', 'Bnx5GIVJ0u2XWwHm47qGpDUg5TDUOmJDpQaZ2jS0h3a7Cs4Cgdz6GLIolcux1mgs', 'xfff@ffg.hj', 3, 5, 'in_progress', NULL, '2025-09-06 00:58:47', '2025-09-05 22:58:30', '2025-09-05 22:58:47'),
('f135ac59-2749-4345-9b15-f11cbac6e240', 'rVmrbwGzBh1MMZJAyK3ZTRNqbhoEw6LB1d9Fu4cbRv0g0ze98FbBpg7GWP9alY4T', 'qgsjsj@gdjd.fhd', 3, 5, 'in_progress', NULL, '2025-09-02 14:06:40', '2025-09-02 12:06:26', '2025-09-02 12:06:40'),
('f476bf83-f8c4-4079-ba96-4a70a8e96e71', 'HkmTucXLwW5THp02Bibju65Lq9Ar9Osw3N5gZHK5LpoNtPD4rICyfsMp7Qb8Dg4u', 'fghjhf@xcg.hj', 3, 5, 'in_progress', NULL, '2025-09-05 23:35:07', '2025-09-05 21:34:52', '2025-09-05 21:35:07'),
('fb9a870d-a01a-4afe-b94a-6001d99a63fa', 'eA4TyYb3eiZjqEejRJlABFSB3XUptlE96sS5y5v5om9MDf2MokqkJzIzXydDnALh', 'ravaosolomarguerite66@gmail.com', 2, 5, 'in_progress', NULL, '2025-09-01 08:51:46', '2025-09-01 06:51:32', '2025-09-01 06:51:46');

-- --------------------------------------------------------

--
-- Structure de la table `registration_step_data`
--

CREATE TABLE `registration_step_data` (
  `id` char(36) NOT NULL,
  `process_id` char(36) NOT NULL,
  `step_number` int(11) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `registration_step_data`
--

INSERT INTO `registration_step_data` (`id`, `process_id`, `step_number`, `data`, `created_at`, `updated_at`) VALUES
('01fbeee4-e5c5-467b-950e-d421012a923e', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 1, '{\"nom_complet\":\"Bambio\",\"email\":\"bambiodoubalogerome73@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$DdNU3hXGLd\\/zJ6vW1yWyLeCYLSb7\\/w.Hqe6aVQH\\/s\\/AabbzuUj4ZO\"}', '2025-09-02 08:22:05', '2025-09-02 08:22:05'),
('09f7e784-4125-4a6c-b5b5-a05c4b7dfc48', 'bda75f27-d76d-4a4f-b362-7885180d8d6b', 3, '{\"competences\":[\"wvbwbw\",\"gshshs\",\"gshjs\"],\"cv_url\":\"cvs\\/cv_1756714546_68b55632c244d.pdf\"}', '2025-09-01 06:15:46', '2025-09-01 06:15:46'),
('0a6f8bef-5617-4182-b015-66e344c84759', 'c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', 3, '[]', '2025-09-02 11:32:50', '2025-09-02 11:32:50'),
('0b5f2844-df70-4862-977a-fb5f854af814', '1574db69-a641-469b-b619-5a7d77a815da', 2, '{\"ecole\":\"hhhh\",\"filiere\":\"hdhsjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-05 22:18:34', '2025-09-05 22:18:34'),
('0d74172a-3c9b-4347-8152-a70def1ad758', 'e82e4dd2-85a1-4f24-a30e-35f64ca1e207', 2, '{\"ecole\":\"Etsrs\",\"filiere\":\"shjsjsjs\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Errachidia\"}', '2025-09-01 07:22:43', '2025-09-01 07:22:43'),
('0fc2f01e-d8c5-4ff3-af05-761302eb8775', '3d6a52fb-6e97-415c-93a2-1fd1902d6439', 1, '{\"nom_complet\":\"hwbwksks dkld\",\"email\":\"sgsjjsj@vjdkd.djdj\",\"telephone\":\"46435464643\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$DbUkY0s9FNTb1RyzPe9eTuMGpXAT3bJ7ov1N4507w4QooCtMMTTMK\"}', '2025-09-05 21:19:47', '2025-09-05 21:19:47'),
('1092ddda-2315-46a2-900a-040723c3991b', '418d80ef-c9c7-4931-9e88-d4e27de84763', 2, '{\"ecole\":\"ghjkkxghju\",\"filiere\":\"fghhh\",\"niveau_etude\":\"Master 1\",\"ville\":\"Errachidia\"}', '2025-09-05 21:25:27', '2025-09-05 21:25:27'),
('121aaea6-cbbd-4848-9d27-01aeb5208f95', 'e289004a-5c97-428b-8711-f18970e5ca37', 2, '{\"ecole\":\"hsjsksk\",\"filiere\":\"zhsjsjkd\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 09:25:26', '2025-09-02 09:25:26'),
('124b4cc6-24a3-46c4-89a3-a735dc9f4d88', '7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 3, '[]', '2025-09-05 22:01:27', '2025-09-05 22:01:27'),
('1260e49e-c99d-4cc7-b6b1-24dd27dd7f2a', '976533e3-a507-4b18-9b13-e756fd67ed2f', 1, '{\"nom_complet\":\"sgsh djdkkd\",\"email\":\"fahsu@hdk.ffb\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$1UKGuKswbNTVkH1\\/a2wDn.Zw.d14gTzIkFvjBppZk9s4hqr0whmOe\"}', '2025-09-02 10:55:26', '2025-09-02 10:55:26'),
('12da2484-ddad-449b-a6dc-841d7adb9add', 'f08fee38-a6f1-46d3-8959-7f5311cf356b', 2, '{\"ecole\":\"ccghh\",\"filiere\":\"fghhhjh\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Essaouira\"}', '2025-09-05 22:58:44', '2025-09-05 22:58:44'),
('13553d81-fc52-4dbf-a25f-697701e62074', '1574db69-a641-469b-b619-5a7d77a815da', 1, '{\"nom_complet\":\"gdjskksks\",\"email\":\"sjjsjsk@vdjd.dhd\",\"telephone\":\"46644654346\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$fcXV\\/6wpXQMHx\\/o\\/tZXvQuApnV2IAvRhqvG\\/.na3T805V82nod8pa\"}', '2025-09-05 22:18:23', '2025-09-05 22:18:23'),
('1499bfe6-4a30-4847-b5f7-b7435d472c55', '5a091233-9de7-40fe-a422-759de9567291', 2, '{\"ecole\":\"chkkkk\",\"filiere\":\"fghjjk\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Errachidia\"}', '2025-09-02 12:36:56', '2025-09-02 12:36:56'),
('15f9dda0-8510-41f8-b2fa-87f0548975f1', '5394c165-7eba-4039-b986-9b73d83d63d8', 1, '{\"nom_complet\":\"Rztzuz\",\"email\":\"fdhsksh@hdkd.dj\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"session_token\":\"UJ4kj93JHTOewsxKanCV21x6V2MKqcrj4sFPOBlhC9u90W4nfGnUBsoZ6koRiAol\",\"password_hash\":\"$2y$12$hvQDN6RS7SP5S\\/aD4DH18uZIkAmm3j06H2GVX.cy7k.0JCorLVm6G\"}', '2025-09-02 09:12:44', '2025-09-02 09:13:09'),
('17e5c0a0-f6d2-4b51-a5c3-ea4681809d25', '9530fcc7-3d10-42b6-82c3-9e0384376364', 3, '[]', '2025-09-02 11:08:34', '2025-09-02 11:08:34'),
('19654fe4-5033-41f6-be43-b7dd4b678dc6', 'f476bf83-f8c4-4079-ba96-4a70a8e96e71', 1, '{\"nom_complet\":\"dfghhj thhj\",\"email\":\"fghjhf@xcg.hj\",\"telephone\":\"5224455785\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$lLAVjOIunG1SHIdBttyiZOmY0L2sFxEHpHxKgS0eTDR\\/0AfqGXXg2\"}', '2025-09-05 21:34:52', '2025-09-05 21:34:52'),
('20460a23-167a-4938-b9a0-e6ffbe5283c0', '85079c96-bb47-4e5f-bccd-9df2361dd874', 1, '{\"nom_complet\":\"sxvsbs djsksksk djkd\",\"email\":\"sghsj@sggs.gh\",\"telephone\":\"123456789\",\"nationalite\":\"Burkina Faso\",\"password_hash\":\"$2y$12$DRqPVtfxif3jYeZ5FXp62uHh2.9Gc8.IF73PgP2sqg3jEi9rl0YvC\"}', '2025-09-02 10:25:11', '2025-09-02 10:25:11'),
('305b47fa-91e5-4259-b104-3b4edfd8feab', '85079c96-bb47-4e5f-bccd-9df2361dd874', 3, '[]', '2025-09-02 10:25:27', '2025-09-02 10:25:27'),
('30a07bcf-410b-4c46-aca5-c53228b930f5', 'fb9a870d-a01a-4afe-b94a-6001d99a63fa', 2, '{\"ecole\":\"ENSAM\",\"filiere\":\"informatique\",\"niveau_etude\":\"Master 2\",\"ville\":\"Errachidia\"}', '2025-09-01 06:51:46', '2025-09-01 06:51:46'),
('31db0d78-dac4-40fa-a677-151e981f5841', 'a9eed21f-6edd-4bcd-94c5-eff032f01d71', 2, '{\"ecole\":\"sgsjksks\",\"filiere\":\"sshjsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 12:12:50', '2025-09-02 12:12:50'),
('32a54ca9-8eed-4629-9bd2-b466bed3f669', 'c3bbf53c-8664-4de7-af9b-4752119f0556', 1, '{\"nom_complet\":\"sgshsj djdj\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$ZtUrOOC5egtP9nUA82Fal.pzM7O5zJJjP0HRy6ZVTcW8WYG3S2tTK\"}', '2025-09-01 07:45:39', '2025-09-01 07:45:39'),
('32c79ad9-4d9a-4437-bc62-9fe811d92632', '9aabb3aa-e915-4a07-8485-c85773adc096', 3, '{\"competences\":[\"gshsh\",\"sgshjs zhjsk\",\"gshsh shjs shjs\"],\"projects\":[{\"id\":\"69c7601d-d9ab-440f-9ca7-714dc129ffdb\",\"title\":\"gshjs\",\"description\":\"sghsj sjsjjs shjs shsjjs\",\"link\":null,\"created_at\":\"2025-09-01T07:25:20+00:00\"}],\"cv_url\":\"cvs\\/cv_1756711520_68b54a6002efd.pdf\"}', '2025-09-01 05:25:20', '2025-09-01 05:25:20'),
('33c607b2-6d53-4f04-bfeb-1be83ff6c1da', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 2, '{\"ecole\":\"rty\",\"filiere\":\"dghu\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '2025-09-05 23:26:49', '2025-09-05 23:26:49'),
('3ebd70d6-610e-4773-b1b7-a4d786cd8290', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 1, '{\"nom_complet\":\"sgsyzjzj\",\"email\":\"sghsjs@sgsj.dhd\",\"telephone\":\"2134684846\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$JxTMDV\\/jq4BMurIa0HACzeCk7Mtwz4X\\/.fVu4.EFPcwQrd1nfibTy\"}', '2025-09-02 11:15:06', '2025-09-02 11:15:06'),
('48eee9e2-4e1f-4a6c-bc9e-08d595b0fcd9', 'a068b4f3-1cf8-4974-b16d-7b0cb32213e9', 3, '[]', '2025-09-02 11:43:47', '2025-09-02 11:43:47'),
('4961dd1e-a442-48ba-bcba-88a464b9dffa', '6cdb793c-96e8-4aae-8382-a140824f64bb', 2, '{\"ecole\":\"vbbj\",\"filiere\":\"bjjj\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-05 22:52:42', '2025-09-05 22:52:42'),
('4b7bfcab-b9fc-4d1e-9bb2-1cd169ba63fd', '64fb5063-d4c2-475c-ab6a-6127be1afa78', 2, '{\"ecole\":\"cvbb\",\"filiere\":\"ghhhh\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Guelmim\"}', '2025-09-05 22:30:00', '2025-09-05 22:30:00'),
('4ddac700-5c9a-40eb-8c85-0132683d8128', '5a091233-9de7-40fe-a422-759de9567291', 1, '{\"nom_complet\":\"xghjk\",\"email\":\"fhjj@fgh.gh\",\"telephone\":\"52366666665\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$eTj4sKR8OEz7Qw646ynL2eb06rlJSGlzIXxKIcv6KPZbt2p5lIWEe\"}', '2025-09-02 12:36:45', '2025-09-02 12:36:45'),
('50665414-6a29-4e0b-8080-e8b142977138', '81af45a1-07f0-4f52-aa39-6116d1ad216a', 1, '{\"nom_complet\":\"fghhh hjjj\",\"email\":\"fgghjj@fgh.bh\",\"telephone\":\"225125556\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$gCXaWKvJhR8gyvqrF0RasuFAm0DzxEjxKPLxwQbOZXtBKE5lqS4ci\"}', '2025-09-05 22:44:37', '2025-09-05 22:44:37'),
('510ced4b-aff1-4256-a00f-06c7f14fe465', '976533e3-a507-4b18-9b13-e756fd67ed2f', 3, '[]', '2025-09-02 10:55:41', '2025-09-02 10:55:41'),
('53fe9279-11b1-4ad2-8680-7b32ab396c62', 'bda75f27-d76d-4a4f-b362-7885180d8d6b', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$rJE\\/4lY8lGOfY1jlD7G0OOnqaTjmBsry8BanuWnjdm7H.YMgvnRNm\"}', '2025-09-01 06:15:00', '2025-09-01 06:15:00'),
('547bd391-11ee-44fc-8cfe-35a686e47fec', '1f79f35a-fcf1-450f-93fb-326185f8c976', 2, '{\"ecole\":\"sghsjs\",\"filiere\":\"shsjjs\",\"niveau_etude\":\"Master 2\",\"ville\":\"F\\u00e8s\"}', '2025-09-01 07:30:57', '2025-09-01 07:30:57'),
('548a7c03-94f6-47dd-acef-92b11cd9e329', '70a80207-3800-47cb-8b0b-2cef290ae030', 2, '{\"ecole\":\"sghsjs djdkkd jskkd\",\"filiere\":\"zhzjsj dkdkkd\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-05 21:11:19', '2025-09-05 21:11:19'),
('554b83e6-e9e7-46c7-a35c-34279175271b', '18fabc8e-7c93-4371-89c0-b203f1eac7c3', 2, '{\"ecole\":\"sgjsj\",\"filiere\":\"sgsjsjsk\",\"niveau_etude\":\"Master 2\",\"ville\":\"Chefchaouen\"}', '2025-09-01 07:03:35', '2025-09-01 07:03:35'),
('5e869515-18ee-4592-8fbc-7eb65c846288', 'a068b4f3-1cf8-4974-b16d-7b0cb32213e9', 2, '{\"ecole\":\"svhsjsk\",\"filiere\":\"gsjsksk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 11:43:44', '2025-09-02 11:43:44'),
('5f05c724-5736-40e1-92fe-efc82d07bc9d', 'e2b37756-5a36-4412-ab35-06fd863cdcdc', 1, '{\"nom_complet\":\"Vvsbs djsjsj\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$5gvlJnbvAA88CVElDXuciOixDBUML5U2ecrBWNd6KSI46xocMfPo6\"}', '2025-09-01 07:36:57', '2025-09-01 07:36:57'),
('6230f938-0e55-4a7c-9a54-6669700c310a', 'e98c4e2d-9594-4097-8eea-871e464519a0', 2, '{\"ecole\":\"fhjjk\",\"filiere\":\"ghjj\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Errachidia\"}', '2025-09-02 12:27:49', '2025-09-02 12:27:49'),
('62325abc-46e0-46ec-81a0-cb6fe4352745', 'a068b4f3-1cf8-4974-b16d-7b0cb32213e9', 1, '{\"nom_complet\":\"zgshjsjs\",\"email\":\"sghsjs@sgsj.djdk\",\"telephone\":\"454312466451\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$MVu4jMhmG.Dwdv0SJo.v0edZutUEwbqKGh4w2BiAVMDLFaC\\/eoACm\"}', '2025-09-02 11:43:35', '2025-09-02 11:43:35'),
('626f6a04-a60d-412d-8ea7-1155b1b70b3a', '1715055c-3cae-438d-b65d-5f4c4aed730c', 2, '{\"ecole\":\"shjsjs\",\"filiere\":\"ztsus sjsk\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '2025-09-02 11:00:15', '2025-09-02 11:00:15'),
('65aa1ae9-ef50-4fa6-8aae-1a6aa57287d0', 'e2b37756-5a36-4412-ab35-06fd863cdcdc', 2, '{\"ecole\":\"sghsjs\",\"filiere\":\"zghsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"F\\u00e8s\"}', '2025-09-01 07:37:07', '2025-09-01 07:37:07'),
('6bcc28f8-5d8c-4b14-b9e7-b38ac10023a2', 'bf3413ae-7489-4b53-ac28-2309529dfe9c', 3, '{\"competences\":[\"shbsbw\"],\"projects\":[{\"id\":\"2c28507f-36ea-415c-aaac-a2640f3bc9e7\",\"title\":\"shsjjs\",\"description\":\"shsjs sjsjjs djdkdk\",\"link\":null,\"created_at\":\"2025-09-01T09:57:53+00:00\"}],\"cv_url\":\"cvs\\/cv_1756720673_68b56e21c15a5.pdf\"}', '2025-09-01 07:57:53', '2025-09-01 07:57:53'),
('6c3acefd-261b-4832-982f-13397371f734', '81af45a1-07f0-4f52-aa39-6116d1ad216a', 3, '[]', '2025-09-05 22:44:50', '2025-09-05 22:44:50'),
('70c4d848-222f-41b1-aafb-a88bd21755f9', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 1, '{\"nom_complet\":\"chbnnk\",\"email\":\"rimkadelorodg@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$fmN8MTaQPvBpBjOUv2oGIexmNUr3Axe5yxFWz4BAWIBxB6fqNg8IC\"}', '2025-09-05 23:26:40', '2025-09-05 23:26:40'),
('71dd29b6-ebef-46d3-ae6a-ed8cae8a9098', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 3, '{\"competences\":[\"ds hsh\",\"fa hshs\"],\"projects\":[{\"id\":\"cb4175dd-df89-4c79-81e1-be41164b4967\",\"title\":\"shjsjs djsjs\",\"description\":\"gshsh sjsks dkdk\",\"link\":null,\"created_at\":\"2025-09-02T10:22:50+00:00\"}],\"cv_url\":\"cvs\\/cv_1756808569_68b6c57945e83.pdf\"}', '2025-09-02 08:22:50', '2025-09-02 08:22:50'),
('73618604-461b-451e-825d-8e44a29f2bd2', '5a091233-9de7-40fe-a422-759de9567291', 3, '[]', '2025-09-02 12:37:00', '2025-09-02 12:37:00'),
('7683e1d2-07ed-4a74-8b94-b78b399e74f7', 'ea75fc5d-5216-4bb0-962c-7898728a0beb', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Master 1\",\"ville\":\"Guelmim\"}', '2025-09-01 05:29:47', '2025-09-01 05:29:47'),
('79dfa469-6afc-4fe0-845c-0c46d3552c7d', '3d6a52fb-6e97-415c-93a2-1fd1902d6439', 2, '{\"ecole\":\"dghjj\",\"filiere\":\"ftyyuu hhj\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-05 21:21:20', '2025-09-05 21:21:20'),
('7aff8411-55c2-4a0f-99a3-a91291575143', '9530fcc7-3d10-42b6-82c3-9e0384376364', 2, '{\"ecole\":\"whshjs\",\"filiere\":\"shjs sjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 11:08:29', '2025-09-02 11:08:29'),
('84e6f88e-beed-4d4c-a310-c33943ddd8a8', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 2, '{\"ecole\":\"gshsjs\",\"filiere\":\"svjsjs\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 11:15:21', '2025-09-02 11:15:21'),
('85554150-8439-45b9-8c63-4f4848d8ae03', '1574db69-a641-469b-b619-5a7d77a815da', 3, '[]', '2025-09-05 22:18:37', '2025-09-05 22:18:37'),
('85fccf15-45cc-43a7-8382-d34e48417faa', '64fb5063-d4c2-475c-ab6a-6127be1afa78', 1, '{\"nom_complet\":\"svbsjs\",\"email\":\"vsjsj@vdh.dhd\",\"telephone\":\"21254643446\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$KdaQ2y1MLapqUUIfLBpt.OkfwrynKHmuL06Aep8c9Lny5iaRMT2\\/C\"}', '2025-09-05 22:29:51', '2025-09-05 22:29:51'),
('86db22aa-35aa-4886-bb9a-8472709ad06f', '9530fcc7-3d10-42b6-82c3-9e0384376364', 1, '{\"nom_complet\":\"shjsjs sjsks\",\"email\":\"fshs@hdj.hj\",\"telephone\":\"123456789\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$SAaMMk3b0BU1pmRoOT7KheSsmGa87TBN3XWMbyEArYFzZe8NFRBKy\"}', '2025-09-02 11:08:01', '2025-09-02 11:08:01'),
('877931f2-29be-4f0d-b713-4fff593b3e56', 'e289004a-5c97-428b-8711-f18970e5ca37', 3, '[]', '2025-09-02 09:25:37', '2025-09-02 09:25:37'),
('8b0d57ea-47bf-40a5-b1e1-c40cfc977c5d', '2f6d7106-4ec5-434b-98cb-9337654bf977', 1, '{\"nom_complet\":\"wvjsjsksk\",\"email\":\"rimkadelorodg@gmail.com\",\"telephone\":\"123154645\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$aUm6eAVeE0WP8NVKJ6BSbO0KjjYesl1BrtxsOaFNhVSuWPKuTEhq2\"}', '2025-09-05 23:19:24', '2025-09-05 23:19:24'),
('8b7267dd-bddb-47e6-a20b-25208917d3f9', '6cdb793c-96e8-4aae-8382-a140824f64bb', 1, '{\"nom_complet\":\"ghjj\",\"email\":\"cghjkk@ty.hj\",\"telephone\":\"222565662\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$FSPcghP4WaHpY0GeEoNsIO2m0vuvVe0uCj6FPi7XaXWEd6BWj8ysO\"}', '2025-09-05 22:52:32', '2025-09-05 22:52:32'),
('8e828405-d034-426a-8a4f-be4436018cc1', 'c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', 1, '{\"nom_complet\":\"dghjj\",\"email\":\"dfgjjk@xcg.hj\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$9n1MOB0Ly3njDHfZzuDFWubpVUFNAC3wGA0Vf8Yjsg1omXYT0xsRa\"}', '2025-09-02 11:32:38', '2025-09-02 11:32:38'),
('8ff8429a-f6f6-4be1-9fd7-8a3c11607b98', 'c67dcfed-a4b9-45b5-aa9c-bccb91696dc2', 2, '{\"ecole\":\"chjkk\",\"filiere\":\"fghjjk\",\"niveau_etude\":\"DUT\",\"ville\":\"El Jadida\"}', '2025-09-02 11:32:47', '2025-09-02 11:32:47'),
('901a2cf4-9484-40f8-afce-d24c70d8af80', '5394c165-7eba-4039-b986-9b73d83d63d8', 2, '{\"ecole\":\"shjsjsjs\",\"filiere\":\"shsjsk\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Dakhla\"}', '2025-09-02 09:12:56', '2025-09-02 09:12:56'),
('917316fc-5a89-4fb0-ad95-859e878f36dc', '1715055c-3cae-438d-b65d-5f4c4aed730c', 1, '{\"nom_complet\":\"sghsjs dhdjdk\",\"email\":\"ffshsjs@gdj.dh\",\"telephone\":\"2354647846\",\"nationalite\":\"Congo (Kinshasa)\",\"password_hash\":\"$2y$12$L5gP3ATUEWhu7byNYCgNdOHrSvrMdT212wxtyY110H9WCQbX40QsG\"}', '2025-09-02 10:59:52', '2025-09-02 10:59:52'),
('9d40c120-5f82-4fa3-a126-618877acc06e', 'bda75f27-d76d-4a4f-b362-7885180d8d6b', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Essaouira\"}', '2025-09-01 06:15:13', '2025-09-01 06:15:13'),
('9fa63bd0-9285-44d5-aa16-f272cf89d0d9', '2f6d7106-4ec5-434b-98cb-9337654bf977', 3, '[]', '2025-09-05 23:19:36', '2025-09-05 23:19:36'),
('a132e62c-22b9-4d92-ad32-a75cb02ee03b', 'f08fee38-a6f1-46d3-8959-7f5311cf356b', 3, '[]', '2025-09-05 22:58:47', '2025-09-05 22:58:47'),
('a13dc329-e336-4782-b932-99d1f23bc421', '5394c165-7eba-4039-b986-9b73d83d63d8', 3, '[]', '2025-09-02 09:13:44', '2025-09-02 09:13:44'),
('a2ee6707-5b58-4837-bf35-cfe745e51f0f', '85079c96-bb47-4e5f-bccd-9df2361dd874', 2, '{\"ecole\":\"shsjjs zjks\",\"filiere\":\"sgjsjdkd\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Dakhla\"}', '2025-09-02 10:25:24', '2025-09-02 10:25:24'),
('a4306084-c62a-4b30-b728-ac9443ff891e', '7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 1, '{\"nom_complet\":\"gshsjs zkks\",\"email\":\"hsjshdh@hdjd.dhd\",\"telephone\":\"15468754864\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$UpbUztYNiOmdI2nynpEkf.HRXPBR0jDr5LXRUjcU.Z1oG3jUx82rS\"}', '2025-09-05 22:01:15', '2025-09-05 22:01:15'),
('a730abb1-697a-4435-9a48-c835d0ce23f8', 'd614a109-f248-4e07-8e2f-ec1e68972d74', 2, '{\"ecole\":\"svhsjsks\",\"filiere\":\"vsjsjjsks\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 12:19:52', '2025-09-02 12:19:52'),
('aafdfe72-285a-41bf-b74a-16edfe4a1a12', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true}', '2025-09-05 23:27:00', '2025-09-05 23:27:00'),
('ab6e2b1a-48e1-4f24-8d99-d50bc473a98e', 'bf3413ae-7489-4b53-ac28-2309529dfe9c', 1, '{\"nom_complet\":\"gdhdjs dhdjdk\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Burkina Faso\",\"password_hash\":\"$2y$12$5uCfoZmn3DvCECA1V1i\\/reJaoPyac6zWneVGnKW4je4B\\/DLwsqIBe\"}', '2025-09-01 07:57:22', '2025-09-01 07:57:22'),
('ac55ad28-1a9c-4a75-8b5c-94d18e464e30', '11106542-eab1-4a8b-aee9-9031a401ee96', 1, '{\"nom_complet\":\"Vjsksns dksl\",\"email\":\"shhsgs@djfj.hk\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$xXz\\/JTZsbxVnwYy6rEYUsOsCvQp2wtJ7L2jxdE9RXEGT6vLpAq6s2\"}', '2025-09-05 21:10:58', '2025-09-05 21:10:58'),
('b1dccd86-5e85-4e33-b17d-dcb8ebc24a36', 'e98c4e2d-9594-4097-8eea-871e464519a0', 1, '{\"nom_complet\":\"rtyyyu\",\"email\":\"fggh@fgh.jj\",\"telephone\":\"455558885\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$EUgu3PfXLXiLrE382LQe2enm4MvjzQj21eIsxp0xVpHvUXMNaQ2Ey\"}', '2025-09-02 12:27:08', '2025-09-02 12:27:08'),
('b32a9245-c0a5-48a9-802d-4fbbd70d4bca', '9a3d0f02-dfd3-4857-b084-b065164c7bed', 3, '[]', '2025-09-05 23:26:51', '2025-09-05 23:26:51'),
('b3831c37-df26-4fc6-8249-ff5cd4807639', '64fb5063-d4c2-475c-ab6a-6127be1afa78', 3, '[]', '2025-09-05 22:30:03', '2025-09-05 22:30:03'),
('ba6685ea-ff6d-459e-923f-019ae3d127d6', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 1, '{\"nom_complet\":\"zhjdkdkd\",\"email\":\"rimkadelorodg@gmail.com\",\"telephone\":\"12318467994\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$LoSFnLFvw9Qa5xAB0tHfSOOuLw635fT3fq1JAow8csORb27W0NlvK\"}', '2025-09-05 23:09:54', '2025-09-05 23:09:54'),
('bb3118a6-6b22-438d-93ab-f2f731cd9e14', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 4, '{\"code_amci\":\"ET2003\",\"affilie_amci\":true}', '2025-09-02 08:23:22', '2025-09-02 08:23:22'),
('bc3b8f22-b56d-46c3-bab5-f4687a0261e4', '6cdb793c-96e8-4aae-8382-a140824f64bb', 3, '[]', '2025-09-05 22:52:45', '2025-09-05 22:52:45'),
('be46d64f-fcf3-4c0a-b9c8-ffd73a8d0107', 'bf3413ae-7489-4b53-ac28-2309529dfe9c', 2, '{\"ecole\":\"tetyeue\",\"filiere\":\"yzyzuzu\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Chefchaouen\"}', '2025-09-01 07:57:32', '2025-09-01 07:57:32'),
('c17dbf4f-aa26-4455-864b-4dba2c99f9b3', '3d6a52fb-6e97-415c-93a2-1fd1902d6439', 3, '[]', '2025-09-05 21:21:23', '2025-09-05 21:21:23'),
('c6580e3d-8db9-4c2b-aa7b-69f6b248b1d4', '70a80207-3800-47cb-8b0b-2cef290ae030', 1, '{\"nom_complet\":\"Vjsksns dksl\",\"email\":\"shhsgs@djfj.hk\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$rWMiVwQ2nd\\/\\/ytCW0qoJo.4QlCemP0va1HOl5xga6bFP9\\/umLbGRa\"}', '2025-09-05 21:11:02', '2025-09-05 21:11:02'),
('c6deecc9-9d81-4b23-8524-cafa02c4b63f', 'e98c4e2d-9594-4097-8eea-871e464519a0', 3, '[]', '2025-09-02 12:27:51', '2025-09-02 12:27:51'),
('c8211848-8351-4d67-8e05-4ee9cb2b92c0', '2e567776-a92b-4946-bad3-ad59c2f28825', 1, '{\"nom_complet\":\"sxvsbs djsksksk djkd\",\"email\":\"sghsj@sggs.gh\",\"telephone\":\"123456789\",\"nationalite\":\"Burkina Faso\",\"password_hash\":\"$2y$12$4lZDyIRkvdwEeJmmAFFw7OknxE7E8MVLdadLf0F9DXjZqYqfKLUXi\"}', '2025-09-02 10:24:42', '2025-09-02 10:24:42'),
('c8498270-b284-4172-bcc5-d9808d219a6e', '81af45a1-07f0-4f52-aa39-6116d1ad216a', 2, '{\"ecole\":\"fghhhj\",\"filiere\":\"fgghhj\",\"niveau_etude\":\"Master 1\",\"ville\":\"Errachidia\"}', '2025-09-05 22:44:48', '2025-09-05 22:44:48'),
('c8962152-ba23-4fa3-9b26-b6d93db1f70e', 'd34fbd88-86f7-42e3-81c4-acd142b687c4', 3, '[]', '2025-09-02 11:15:36', '2025-09-02 11:15:36'),
('cb6cb4a9-6196-45cf-8123-c5dd3f6c5424', 'f08fee38-a6f1-46d3-8959-7f5311cf356b', 1, '{\"nom_complet\":\"xcghhj\",\"email\":\"xfff@ffg.hj\",\"telephone\":\"555225585\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$1FBF21DMmliBBL5csKBbE.HIRQhobh4INjHA3z3mUkFsYsczWhkW2\"}', '2025-09-05 22:58:30', '2025-09-05 22:58:30'),
('cba5e32f-bd4f-492c-8b61-cb84da2bf987', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 1, '{\"nom_complet\":\"reydyeueu\",\"email\":\"zcshudud@dvhd.bj\",\"telephone\":\"5464612428\",\"nationalite\":\"Comores\",\"session_token\":\"YjQ39CKJehQJReELDncJEi9KtSOTnUe9W7OM48xrMgPrV235cRnZdOwSBMFwDGJx\",\"password_hash\":\"$2y$12$GrynVR5EPZDFvERonV7kFeGRrtgxoYStxznI9NuHjT0tMOiSb\\/W1C\"}', '2025-09-02 11:25:43', '2025-09-02 11:26:42'),
('cbb6d21e-dd53-4c77-8359-28892ef01e2b', 'ea75fc5d-5216-4bb0-962c-7898728a0beb', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123546789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$D5YxCfv8Sw5pHDxKu0BQPeLpf6yw5wxgGhobQ4Q1457h9D55.EGei\"}', '2025-09-01 05:29:36', '2025-09-01 05:29:36'),
('ccb599e7-5ef2-4d76-a3c5-54a8c2227402', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 3, '[]', '2025-09-05 23:10:06', '2025-09-05 23:10:06'),
('cea0ee7c-ce3d-4c8f-8eb2-48345c9e871c', 'ea75fc5d-5216-4bb0-962c-7898728a0beb', 3, '{\"competences\":[\"hhbs shsjs sjsk\",\"sghsjs djdkd jdjsk\"],\"projects\":[{\"id\":\"9b32b2c6-cdbc-4b92-b21f-47cec6397bca\",\"title\":\"gshsh sjsks sjsk\",\"description\":\"sgshjs sjsksk sjskns\",\"link\":null,\"created_at\":\"2025-09-01T07:30:19+00:00\"}],\"cv_url\":\"cvs\\/cv_1756711819_68b54b8b56217.pdf\"}', '2025-09-01 05:30:19', '2025-09-01 05:30:19'),
('d04b5b50-aee0-4d6d-a7a5-20e1f6dd7202', 'a9eed21f-6edd-4bcd-94c5-eff032f01d71', 3, '[]', '2025-09-02 12:12:52', '2025-09-02 12:12:52'),
('d15626e9-895a-4edc-aef7-59da78c0d281', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 3, '[]', '2025-09-02 11:25:57', '2025-09-02 11:25:57'),
('d4375e1d-2110-4ad0-82bc-dfdf2c041c56', 'c3bbf53c-8664-4de7-af9b-4752119f0556', 2, '{\"ecole\":\"sghssh\",\"filiere\":\"sgshs djdj\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-01 07:45:49', '2025-09-01 07:45:49'),
('d4a7ffb4-c8f1-447d-828f-2b758ac74ec7', '4d17d578-3cc2-4fc0-a896-b75ae6635fb6', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 08:22:23', '2025-09-02 08:22:23'),
('d5b1b685-3974-4eb5-89b9-b413e119374a', '976533e3-a507-4b18-9b13-e756fd67ed2f', 2, '{\"ecole\":\"sghsjs\",\"filiere\":\"sgzysu sjdjd\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-02 10:55:38', '2025-09-02 10:55:38'),
('d5b710ed-37f2-4925-8c5e-b1eca71fae5a', 'e82e4dd2-85a1-4f24-a30e-35f64ca1e207', 1, '{\"nom_complet\":\"svbsnwn sbsjks snsk\'s\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Burundi\",\"password_hash\":\"$2y$12$MFZ\\/Ybz9V8V.0aPXENGRTu6\\/7yG7BnATiEB4vcBjRIZ9gSH.Rdtvi\"}', '2025-09-01 07:22:32', '2025-09-01 07:22:32'),
('d80340e6-8d5b-4988-9db8-b9513c588206', 'f476bf83-f8c4-4079-ba96-4a70a8e96e71', 3, '[]', '2025-09-05 21:35:07', '2025-09-05 21:35:07'),
('dae1f209-a33e-498a-a47a-0df1c029e2d9', '7c2ae77f-13dd-4e21-beba-bbc7e2b1840e', 2, '{\"ecole\":\"sghshsb\",\"filiere\":\"ztayhs sjksks\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-05 22:01:25', '2025-09-05 22:01:25'),
('dbfc1c6c-8a1a-4765-960a-39217299a0a3', 'fb9a870d-a01a-4afe-b94a-6001d99a63fa', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$GTEq9WbudCUK.B52zT9b1OKuv2gdjlILrfyseNJ6PqKo7QYYJANwW\"}', '2025-09-01 06:51:32', '2025-09-01 06:51:32'),
('dc7f2c88-9bac-4924-b1bf-fe9e01a41c23', 'f135ac59-2749-4345-9b15-f11cbac6e240', 3, '[]', '2025-09-02 12:06:40', '2025-09-02 12:06:40'),
('e0b2f1f7-ff98-485d-a105-b7b0dd91bd4c', 'e289004a-5c97-428b-8711-f18970e5ca37', 1, '{\"nom_complet\":\"sghsjs dkdlld\",\"email\":\"sghsjs@hsj.ghf\",\"telephone\":\"213546789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$lxLsdjc1ekr5RAWzpIQ8QuSmShOrQEAvCJR0zokEXAPzCl41sp0ES\"}', '2025-09-02 09:25:14', '2025-09-02 09:25:14'),
('e146e435-a0a1-4db2-8e8b-affac9241693', '790b195d-4de9-4df0-a2d3-59868911ecb0', 1, '{\"nom_complet\":\"Vjsksns dksl\",\"email\":\"shhsgs@djfj.hk\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$zjJSLKkEGG0JUPT3MVrTD.\\/V9FxtC1CqctGzXAQtn.4A0rB7a4vTC\"}', '2025-09-05 21:10:56', '2025-09-05 21:10:56'),
('e2af9ff9-1cf4-44c9-9a46-cafdcfaaa802', '1f79f35a-fcf1-450f-93fb-326185f8c976', 1, '{\"nom_complet\":\"shjsjs ds sns\'\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$PaWJP1UPv\\/WJGTkrDcR\\/UeSyIswvuIN3Y3qTTHExoa06oVIlJB93C\"}', '2025-09-01 07:30:44', '2025-09-01 07:30:44'),
('e4dcb4d3-4940-4649-8830-64d3726324d2', 'a9eed21f-6edd-4bcd-94c5-eff032f01d71', 1, '{\"nom_complet\":\"gshsjs\",\"email\":\"sghsjs@sgsj.djdk\",\"telephone\":\"543464546461\",\"nationalite\":\"Cap-Vert\",\"password_hash\":\"$2y$12$IkwpQ.7ShJgAt1\\/2dxrjv.r19fIF\\/4eyF6ufwNqRk.FVn1XIJrhuG\"}', '2025-09-02 12:12:40', '2025-09-02 12:12:40'),
('e6278c69-5550-4ee3-97cc-a5dcff142938', '9aabb3aa-e915-4a07-8485-c85773adc096', 2, '{\"ecole\":\"EST\",\"filiere\":\"informatique\",\"niveau_etude\":\"Licence 3\",\"ville\":\"El Jadida\"}', '2025-09-01 05:24:37', '2025-09-01 05:24:37'),
('e68180a8-cd24-4422-8f64-108b680ca1b3', 'f476bf83-f8c4-4079-ba96-4a70a8e96e71', 2, '{\"ecole\":\"cgghh yjj\",\"filiere\":\"gghh hjjjj\",\"niveau_etude\":\"Ing\\u00e9nieur\",\"ville\":\"Essaouira\"}', '2025-09-05 21:35:05', '2025-09-05 21:35:05'),
('e8d11dcf-ab9c-425e-886e-4f9913a6b059', '418d80ef-c9c7-4931-9e88-d4e27de84763', 3, '[]', '2025-09-05 21:25:30', '2025-09-05 21:25:30'),
('e9a7f2d8-9f27-4dba-bdfe-f956c9ddf16c', '70a80207-3800-47cb-8b0b-2cef290ae030', 3, '[]', '2025-09-05 21:11:23', '2025-09-05 21:11:23'),
('e9e15b62-8383-43f9-8ea6-38505ae81aa4', '20ca7ceb-9a08-4940-80dd-0cf2be8c57f1', 2, '{\"ecole\":\"wvsvbs\",\"filiere\":\"gshhs\",\"niveau_etude\":\"Master 2\",\"ville\":\"Essaouira\"}', '2025-09-02 11:25:53', '2025-09-02 11:25:53'),
('ec24c649-78dd-43ff-b652-93d7d9fbe672', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 2, '{\"ecole\":\"sfhsjsjs\",\"filiere\":\"schsjsn\",\"niveau_etude\":\"Doctorat\",\"ville\":\"Essaouira\"}', '2025-09-05 23:10:04', '2025-09-05 23:10:04'),
('f5975651-ec01-483e-84f5-3e30033db9e3', 'd614a109-f248-4e07-8e2f-ec1e68972d74', 3, '[]', '2025-09-02 12:19:55', '2025-09-02 12:19:55'),
('f59c7baa-75be-4a74-8d98-42ef1c571bb9', '18fabc8e-7c93-4371-89c0-b203f1eac7c3', 1, '{\"nom_complet\":\"shjsjs dkdlld\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"123456789\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$YtOASmoehQUKvL4RF48RR.Nkazu5ol9Xj\\/10XqX4Mvph1evRWdx4i\"}', '2025-09-01 07:03:26', '2025-09-01 07:03:26'),
('f5a26b92-baeb-49b2-be45-8ba3ef1b5e4f', 'd614a109-f248-4e07-8e2f-ec1e68972d74', 1, '{\"nom_complet\":\"vdjsjs\",\"email\":\"hshs@gshs.dhdj\",\"telephone\":\"64345494894\",\"nationalite\":\"Comores\",\"password_hash\":\"$2y$12$xM\\/LyX8u1CTjRDu514yqL.YWPVitdrRJQYz.nFOEMv8uMH7HK6u4S\"}', '2025-09-02 12:19:44', '2025-09-02 12:19:44'),
('f71d29cd-b71e-4913-962e-b3a7d1649c67', 'f135ac59-2749-4345-9b15-f11cbac6e240', 1, '{\"nom_complet\":\"hsjsj\",\"email\":\"qgsjsj@gdjd.fhd\",\"telephone\":\"5464849484978\",\"nationalite\":\"Congo (Brazzaville)\",\"password_hash\":\"$2y$12$DZOWocZpicc.PdPOaOeBcu94OyzqmWd2IV\\/2yiJsdQtd49tLPEZam\"}', '2025-09-02 12:06:27', '2025-09-02 12:06:27'),
('f90a44d1-399c-40f7-87ce-1d09e1e5f485', 'f135ac59-2749-4345-9b15-f11cbac6e240', 2, '{\"ecole\":\"wvwbnw\",\"filiere\":\"shsjsjs djdjd\",\"niveau_etude\":\"Licence 3\",\"ville\":\"Dakhla\"}', '2025-09-02 12:06:37', '2025-09-02 12:06:37'),
('fae0c95d-41bd-4f49-86de-7e7eb8e3fd23', '418d80ef-c9c7-4931-9e88-d4e27de84763', 1, '{\"nom_complet\":\"dthj\",\"email\":\"fghjkk@ffg.ghj\",\"telephone\":\"123456789\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$NKurxQp6aJ49oPc7YBPnaucNP5h6Q8mKCzwVZgsjiqsGRBwj.ASvi\"}', '2025-09-05 21:25:10', '2025-09-05 21:25:10'),
('fb2e9728-70e6-45d3-b4e0-0c32b6ad5017', 'cb06a9ec-98e4-420f-ba5d-57f126a9747c', 4, '{\"code_amci\":\"ET2004\",\"affilie_amci\":true}', '2025-09-05 23:10:18', '2025-09-05 23:10:18'),
('fbb146c5-2024-4b38-833c-39c472132362', '1715055c-3cae-438d-b65d-5f4c4aed730c', 3, '[]', '2025-09-02 11:00:18', '2025-09-02 11:00:18'),
('fc1484fb-488e-4f34-876b-1ca9d8402357', '2f6d7106-4ec5-434b-98cb-9337654bf977', 2, '{\"ecole\":\"hdhshd\",\"filiere\":\"cshsjbs\",\"niveau_etude\":\"Master 2\",\"ville\":\"El Jadida\"}', '2025-09-05 23:19:33', '2025-09-05 23:19:33'),
('fd6f9caa-03b2-4d12-bc3b-5f00eef3e147', '9aabb3aa-e915-4a07-8485-c85773adc096', 1, '{\"nom_complet\":\"Ravaosolo Marguerite\",\"email\":\"ravaosolomarguerite66@gmail.com\",\"telephone\":\"0987654321\",\"nationalite\":\"Cameroun\",\"password_hash\":\"$2y$12$u5qOac9x6Ksur9mMM4KdG.y0OCo0R3kQHdHDtnpJDMBYdULTlSLOi\"}', '2025-09-01 05:24:22', '2025-09-01 05:24:22');

-- --------------------------------------------------------

--
-- Structure de la table `reports`
--

CREATE TABLE `reports` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `author_name` varchar(255) NOT NULL,
  `title` varchar(500) NOT NULL,
  `type` enum('PFE','PFA') NOT NULL,
  `defense_year` int(11) NOT NULL,
  `domain` enum('Informatique & Numérique','Génie & Technologies','Sciences & Mathématiques','Économie & Gestion','Droit & Sciences politiques','Médecine & Santé','Arts & Lettres','Enseignement & Pédagogie','Agronomie & Environnement','Tourisme & Hôtellerie','Autres') NOT NULL,
  `description` text DEFAULT NULL,
  `keywords` varchar(500) DEFAULT NULL,
  `pdf_path` varchar(255) NOT NULL,
  `status` enum('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  `admin_id` bigint(20) UNSIGNED DEFAULT NULL,
  `admin_comment` text DEFAULT NULL,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `reports`
--

INSERT INTO `reports` (`id`, `user_id`, `author_name`, `title`, `type`, `defense_year`, `domain`, `description`, `keywords`, `pdf_path`, `status`, `admin_id`, `admin_comment`, `submitted_at`, `processed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 2, 'fty jkkk jkkk kkkk', 'fgg jjk jkkk', 'PFE', 2005, 'Médecine & Santé', NULL, NULL, 'reports/me00NO9qGN1W87NQZsaOMPzeZ6tJbhBcNWrWGUQE.pdf', 'accepted', 2, NULL, '2025-08-30 21:39:52', '2025-09-01 08:24:40', '2025-08-30 21:39:52', '2025-09-01 08:24:40', NULL),
(2, 2, 'ggg jkkk kkkk', 'ghhhhh', 'PFA', 2005, 'Droit & Sciences politiques', NULL, NULL, 'reports/fXD9TDu2Dw5Vd7vGwWkrscs5B3Cf9ZX6B7F5JqaJ.pdf', 'accepted', 2, NULL, '2025-08-31 02:40:20', '2025-08-31 03:06:04', '2025-08-31 02:40:20', '2025-08-31 03:06:04', NULL),
(3, 2, 'agzuz ksksk sklslz', 'shjsjs skkskz sklslz', 'PFE', 2004, 'Médecine & Santé', NULL, NULL, 'reports/h1vwzAU8i5aLbUeG9MVkgAgopC7mRUnn6HQDA3pR.pdf', 'accepted', 2, NULL, '2025-08-31 07:37:27', '2025-09-06 06:32:54', '2025-08-31 07:37:27', '2025-09-06 06:32:54', NULL),
(4, 2, 'hsjs sjsks ksks', 'vwjsbw sjsksk dkskkdks', 'PFA', 2003, 'Arts & Lettres', NULL, NULL, 'reports/r4zT8HbzKuHNRW5y9C45S21AlRE7r30j281px0Zp.pdf', 'accepted', 2, NULL, '2025-09-01 08:24:19', '2025-09-06 06:31:55', '2025-09-01 08:24:19', '2025-09-06 06:31:55', NULL),
(6, 2, 'yessssss', 'patatiiiiiii', 'PFA', 2005, 'Droit & Sciences politiques', NULL, NULL, 'reports/LbxwIEu7wzjY3AX6gzC1XVIqsM7TFQdixXkvMxhI.pdf', 'accepted', 2, NULL, '2025-09-06 06:33:44', '2025-09-06 06:34:58', '2025-09-06 06:33:44', '2025-09-06 06:34:58', NULL);

-- --------------------------------------------------------

--
-- Structure de la table `roles`
--

CREATE TABLE `roles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `roles`
--

INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41'),
(2, 'etudiant', 'web', '2025-08-30 01:12:41', '2025-08-30 01:12:41');

-- --------------------------------------------------------

--
-- Structure de la table `role_has_permissions`
--

CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `role_has_permissions`
--

INSERT INTO `role_has_permissions` (`permission_id`, `role_id`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(6, 2),
(7, 1),
(7, 2),
(8, 1),
(8, 2);

-- --------------------------------------------------------

--
-- Structure de la table `scholarships`
--

CREATE TABLE `scholarships` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `country` varchar(255) NOT NULL,
  `amci_matricule` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `passport` varchar(255) NOT NULL,
  `unknown_field` varchar(255) DEFAULT NULL,
  `scholarship_code` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `scholarships`
--

INSERT INTO `scholarships` (`id`, `country`, `amci_matricule`, `name`, `passport`, `unknown_field`, `scholarship_code`, `created_at`, `updated_at`) VALUES
(1, 'Congo', 'AAA67389', 'Marguerite', '2024D45H56', 'HFK', '1234|132459949464', '2025-09-01 09:19:18', '2025-09-01 09:19:18'),
(3, 'Namibi', 'ETUZ2452', 'Gaezrz', '13424GHY5646', NULL, '1223425|25356388', '2025-09-01 09:19:18', '2025-09-01 09:19:18'),
(5, 'Madagascar', 'ET2001', 'Maer', '244253HFY56', NULL, '12342|3664674747', '2025-09-01 09:54:21', '2025-09-01 09:54:21'),
(6, 'Cote d\'Ivoire', 'HHDHH', 'Faerzr', '1232435HR674', NULL, '1423|74848949499', '2025-09-01 09:54:21', '2025-09-01 09:54:21');

-- --------------------------------------------------------

--
-- Structure de la table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `types_competences`
--

CREATE TABLE `types_competences` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom_complet` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `nationalite` varchar(255) DEFAULT NULL,
  `niveau_etude` varchar(255) DEFAULT NULL,
  `ville` varchar(255) DEFAULT NULL,
  `cv_url` varchar(255) DEFAULT NULL,
  `profile_image_url` varchar(255) DEFAULT NULL,
  `competences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`competences`)),
  `affilie_amci` tinyint(1) NOT NULL DEFAULT 0,
  `code_amci` varchar(255) DEFAULT NULL,
  `matricule_amci` varchar(50) DEFAULT NULL,
  `domaine_etude` varchar(255) DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `verification_code_expires_at` timestamp NULL DEFAULT NULL,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 0,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `ecole` varchar(255) DEFAULT NULL,
  `filiere` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `projects` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`projects`)),
  `registration_status` enum('pending','approved','rejected','incomplete','completed') NOT NULL DEFAULT 'pending',
  `registration_completed_at` timestamp NULL DEFAULT NULL,
  `registration_process_id` char(36) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `nom_complet`, `email`, `password`, `telephone`, `nationalite`, `niveau_etude`, `ville`, `cv_url`, `profile_image_url`, `competences`, `affilie_amci`, `code_amci`, `matricule_amci`, `domaine_etude`, `verification_token`, `verification_code_expires_at`, `is_verified`, `email_verified_at`, `is_approved`, `status`, `ecole`, `filiere`, `created_at`, `updated_at`, `deleted_at`, `projects`, `registration_status`, `registration_completed_at`, `registration_process_id`, `remember_token`) VALUES
(1, 'Test Étudiant', 'etudiant@test.com', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '(541) 306-0979', 'France', 'Master', 'Greenholttown', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:41', 1, 'active', 'EMI', 'Mécanique', '2025-08-30 01:12:42', '2025-08-30 01:12:42', NULL, '[]', 'completed', NULL, NULL, '1ONuNuVCJb'),
(2, 'Super Admin', 'admin@cesam.com', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '+212600000000', 'Maroc', 'Licence', 'Rolfsonport', 'cvs/cv_2_1756711018.pdf', 'profiles/drFVN65GaO9hdHAnIQXpuoBIZ76njeZWFOoE53GW.jpg', '[\"dgshjs\",\"shhsjs dksks dkkd\"]', 0, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:42', 1, 'active', 'EST', 'Informatique', '2025-08-30 01:12:42', '2025-09-06 08:02:51', NULL, '[{\"id\":\"68b5482eae6cd\",\"title\":\"vshsjs djskkd\",\"description\":\"shsusk djsksksk\",\"link\":null,\"created_at\":\"2025-09-01T07:15:58+00:00\"},{\"id\":\"68b548473fefa\",\"title\":\"shhsjs sjsksk sksks\",\"description\":\"shjsjs sksks\",\"link\":\"https:\\/\\/gdhjs.com\",\"created_at\":\"2025-09-01T07:16:23+00:00\"},{\"id\":\"68b574b893fa1\",\"title\":\"autre projet\",\"description\":\"autre autre\",\"link\":null,\"created_at\":\"2025-09-01T10:26:00+00:00\"},{\"id\":\"68b58dcceba8f\",\"title\":\"sgshjs djsksk\",\"description\":\"shsjsjs dkdkdk\",\"link\":null,\"created_at\":\"2025-09-01T12:13:00+00:00\"}]', 'completed', NULL, NULL, 'DnHXMlldDE'),
(3, 'Anya Reichel', 'vicenta.stokes@example.net', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '559.614.8240', 'Sénégal', 'Licence', 'New Rogelio', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:42', 1, 'active', 'EMI', 'Informatique', '2025-08-30 01:12:42', '2025-08-30 01:12:42', NULL, '[]', 'completed', NULL, NULL, 'FJu6Zb17bq'),
(4, 'Jamey Dooley', 'daphnee97@example.org', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '+1-318-232-2974', 'Tunisie', 'Doctorat', 'Port Budshire', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:42', 1, 'active', 'ENSIAS', 'Informatique', '2025-08-30 01:12:42', '2025-08-30 01:12:42', NULL, '[]', 'completed', NULL, NULL, 'qO995xwyCJ'),
(5, 'Miss Emma Lehner MD', 'langosh.conor@example.org', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '+1-959-392-4685', 'France', 'Doctorat', 'Maiyaborough', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:42', 1, 'active', 'ENSIAS', 'Électronique', '2025-08-30 01:12:42', '2025-08-30 01:12:42', NULL, '[]', 'completed', NULL, NULL, 'obTHrFZ2ic'),
(6, 'Mr. Vance Flatley', 'gsenger@example.org', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '+1-210-645-9050', 'France', 'Licence', 'New Alia', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:42', 1, 'active', 'EMI', 'Génie Civil', '2025-08-30 01:12:42', '2025-08-30 01:12:42', NULL, '[]', 'completed', NULL, NULL, '80WimTxBL7'),
(7, 'Dedrick Frami III', 'bennett50@example.org', '$2y$12$d3wdAjQQOvxpjmSxcOGMG.JGkb5WRSBjQk3a/15meBsQAuwUICcWG', '+1.272.819.0906', 'Maroc', 'Doctorat', 'Cormiertown', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 1, '2025-08-30 01:12:42', 1, 'active', 'INPT', 'Mécanique', '2025-08-30 01:12:42', '2025-08-30 01:12:42', NULL, '[]', 'completed', NULL, NULL, 'eDcOoKoMtK'),
(9, 'vsjsksk', 'rnotsimbinina@gmail.com', '$2y$12$mxXjmsqP95IbFnOwRChAKeBz8SRM6iDChtTegGQr.fXBpMiwRI.Py', '123456879', 'Congo (Brazzaville)', 'Doctorat', 'El Jadida', '/storage/cvs/cv_1756524458_68b26faa36f73.pdf', NULL, '[\"sghsj\",\"sgshs\"]', 1, 'ET22002', 'ET22002', NULL, NULL, NULL, 1, '2025-08-30 01:28:31', 1, 'active', 'wvbwkw', 'ztsus dkdkkd', '2025-08-30 01:28:31', '2025-08-30 01:28:58', NULL, '[]', 'pending', '2025-08-30 01:28:31', NULL, NULL),
(10, 'Sambaniarifetra Keren', 'ksambaniarifetra@gmail.com', '$2y$12$ueOXFav7D2c8.K1DDhDIl.QeqgPy2O4xgA9ZowoXx82rTXv7XVATK', '987654321', 'Cap-Vert', 'Master 1', 'Errachidia', '/storage/cvs/cv_1756678693_68b4ca255d4b2.pdf', NULL, '[\"shjsjs ekekzk\",\"zgyzuz zjzjzk\"]', 1, 'ET2003', 'ET2003', NULL, NULL, NULL, 1, '2025-08-31 20:21:24', 1, 'active', 'Ensam', 'productive', '2025-08-31 20:21:24', '2025-08-31 20:22:10', NULL, '[]', 'pending', '2025-08-31 20:21:24', NULL, NULL),
(13, 'Bambio', 'bambiodoubalogerome73@gmail.com', '$2y$12$MnHE/bbkQiIcQK0vqvVAf.V4bb6/ccisbO3cdDHfoU/1/owRrl9Aq', '123456789', 'Bénin', 'Doctorat', 'Guelmim', 'cvs/cv_1756808782_68b6c64e3a1e4.pdf', NULL, '[\"gshs\"]', 1, 'Et2002', 'Et2002', NULL, NULL, NULL, 1, '2025-09-02 08:26:55', 0, 'active', 'Est', 'informatique', '2025-09-02 08:26:56', '2025-09-02 08:26:56', NULL, '[{\"id\":\"018735bb-05c9-492f-92ce-4ceeafc9a3a5\",\"title\":\"shsjjs dhsj\",\"description\":\"vsjs dkdk disn\",\"link\":null,\"created_at\":\"2025-09-02T10:26:22+00:00\"}]', 'pending', '2025-09-02 08:26:55', NULL, NULL),
(14, 'Marguerite', 'ravaosolomargueritemarie@gmail.com', '$2y$12$/oiJ50mbf38Z08l5qguj5esjEdfamKq4gB9WGA1jGyUwRaXPdfH7G', '123456789', 'Cap-Vert', 'Doctorat', 'Essaouira', 'cvs/cv_1756809372_68b6c89c89e1c.pdf', NULL, '[\"wgshsj\"]', 1, 'ET2003', 'ET2003', NULL, NULL, NULL, 1, '2025-09-02 08:43:51', 1, 'active', 'ENsam', 'informatique', '2025-09-02 08:43:51', '2025-09-06 15:46:40', NULL, '[{\"id\":\"8de140f9-434e-4d25-a909-8282413a3ff3\",\"title\":\"shhsjs endks\",\"description\":\"hsjsj dhsjsj\",\"link\":null,\"created_at\":\"2025-09-02T10:36:12+00:00\"}]', 'pending', '2025-09-02 08:43:51', NULL, NULL),
(15, 'cchjj', 'ravaosolomarguerite66@gmail.com', '$2y$12$lwNtlhm2.zL3khLbaFFa5Ol1pwD38V2403l5NgYvyBRZiqhBi1pXW', '123456789', 'Cap-Vert', 'Ingénieur', 'El Jadida', NULL, NULL, '[\"shjsjs\"]', 1, 'ET2004', 'ET2004', NULL, NULL, NULL, 1, '2025-09-05 23:43:44', 1, 'active', 'dgghhj', 'fghjjk', '2025-09-05 23:43:45', '2025-09-06 15:49:18', NULL, '[{\"id\":\"68bc7418d0cb3\",\"title\":\"shhsjzj djdk\",\"description\":\"shsjjs dkkdkd wjjs\",\"link\":null,\"created_at\":\"2025-09-06T17:49:12+00:00\"}]', 'pending', '2025-09-05 23:43:44', NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `user_profiles`
--

CREATE TABLE `user_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `ecole` varchar(255) DEFAULT NULL,
  `filiere` varchar(255) DEFAULT NULL,
  `niveau_etude` varchar(255) DEFAULT NULL,
  `ville` varchar(255) DEFAULT NULL,
  `affilie_amci` tinyint(1) NOT NULL DEFAULT 0,
  `matricule_amci` varchar(255) DEFAULT NULL,
  `cv_url` varchar(255) DEFAULT NULL,
  `biographie` text DEFAULT NULL,
  `photo_profil` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `videos`
--

CREATE TABLE `videos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `titre` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `url` varchar(500) NOT NULL,
  `miniature` varchar(255) DEFAULT NULL,
  `theme` enum('Chaîne TV étudiante','Documentaires & Films') NOT NULL,
  `is_live` tinyint(1) NOT NULL DEFAULT 0,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `duree` int(11) DEFAULT NULL,
  `vues` int(11) NOT NULL DEFAULT 0,
  `likes` int(11) NOT NULL DEFAULT 0,
  `date_publication` datetime NOT NULL DEFAULT '2025-08-31 16:58:49',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `auteur_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `videos`
--

INSERT INTO `videos` (`id`, `titre`, `description`, `url`, `miniature`, `theme`, `is_live`, `is_active`, `duree`, `vues`, `likes`, `date_publication`, `created_at`, `updated_at`, `auteur_id`) VALUES
(1, 'Kalina', NULL, 'https://www.youtube.com/watch?v=T2dtWN18lAk', NULL, 'Chaîne TV étudiante', 0, 1, NULL, 0, 0, '2025-08-31 17:26:11', '2025-08-31 15:26:11', '2025-08-31 15:26:11', 2),
(2, 'vidéo 2', NULL, 'https://www.youtube.com/watch?v=nvTzbCWM2uw&list=RDGMEMgGOgHdkrBSNHvacS9Sp8bg&index=27', NULL, 'Chaîne TV étudiante', 0, 1, NULL, 0, 0, '2025-09-01 12:07:24', '2025-09-01 10:07:24', '2025-09-01 10:07:24', 2),
(3, 'vidéo 3 vidéo 3', NULL, 'https://www.youtube.com/watch?v=kPa7bsKwL-c', NULL, 'Chaîne TV étudiante', 0, 1, NULL, 0, 3, '2025-09-01 12:09:38', '2025-09-01 10:09:38', '2025-09-06 15:48:02', 2);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `applications`
--
ALTER TABLE `applications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `applications_user_id_offer_id_unique` (`user_id`,`offer_id`),
  ADD KEY `applications_offer_id_foreign` (`offer_id`);

--
-- Index pour la table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Index pour la table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Index pour la table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Index pour la table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Index pour la table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `likes`
--
ALTER TABLE `likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `likes_user_id_video_id_unique` (`user_id`,`video_id`),
  ADD KEY `likes_video_id_foreign` (`video_id`);

--
-- Index pour la table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  ADD KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Index pour la table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  ADD KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`);

--
-- Index pour la table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_notifiable_type_notifiable_id_index` (`notifiable_type`,`notifiable_id`);

--
-- Index pour la table `offers`
--
ALTER TABLE `offers`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `password_reset_codes`
--
ALTER TABLE `password_reset_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `password_reset_codes_email_code_index` (`email`,`code`),
  ADD KEY `password_reset_codes_expires_at_index` (`expires_at`),
  ADD KEY `password_reset_codes_email_index` (`email`),
  ADD KEY `password_reset_codes_token_index` (`token`);

--
-- Index pour la table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Index pour la table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`);

--
-- Index pour la table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Index pour la table `projects`
--
ALTER TABLE `projects`
  ADD PRIMARY KEY (`id`),
  ADD KEY `projects_user_id_foreign` (`user_id`);

--
-- Index pour la table `projets`
--
ALTER TABLE `projets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `projets_user_id_foreign` (`user_id`);

--
-- Index pour la table `quotes`
--
ALTER TABLE `quotes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `quotes_submitted_by_foreign` (`submitted_by`);

--
-- Index pour la table `registration_audit_logs`
--
ALTER TABLE `registration_audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `registration_audit_logs_process_id_action_index` (`process_id`,`action`),
  ADD KEY `registration_audit_logs_created_at_index` (`created_at`);

--
-- Index pour la table `registration_processes`
--
ALTER TABLE `registration_processes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registration_processes_session_token_unique` (`session_token`),
  ADD KEY `registration_processes_status_created_at_index` (`status`,`created_at`),
  ADD KEY `registration_processes_expires_at_index` (`expires_at`),
  ADD KEY `registration_processes_user_email_index` (`user_email`);

--
-- Index pour la table `registration_step_data`
--
ALTER TABLE `registration_step_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registration_step_data_process_id_step_number_unique` (`process_id`,`step_number`),
  ADD KEY `registration_step_data_step_number_index` (`step_number`);

--
-- Index pour la table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reports_admin_id_foreign` (`admin_id`),
  ADD KEY `reports_status_type_index` (`status`,`type`),
  ADD KEY `reports_defense_year_status_index` (`defense_year`,`status`),
  ADD KEY `reports_user_id_status_index` (`user_id`,`status`),
  ADD KEY `reports_submitted_at_index` (`submitted_at`),
  ADD KEY `reports_processed_at_index` (`processed_at`),
  ADD KEY `reports_domain_status_index` (`domain`,`status`);

--
-- Index pour la table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`);

--
-- Index pour la table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD PRIMARY KEY (`permission_id`,`role_id`),
  ADD KEY `role_has_permissions_role_id_foreign` (`role_id`);

--
-- Index pour la table `scholarships`
--
ALTER TABLE `scholarships`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `scholarships_amci_matricule_unique` (`amci_matricule`);

--
-- Index pour la table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Index pour la table `types_competences`
--
ALTER TABLE `types_competences`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_registration_process_id_foreign` (`registration_process_id`);

--
-- Index pour la table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_profiles_user_id_unique` (`user_id`);

--
-- Index pour la table `videos`
--
ALTER TABLE `videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `videos_is_active_theme_index` (`is_active`,`theme`),
  ADD KEY `videos_is_live_index` (`is_live`),
  ADD KEY `videos_date_publication_index` (`date_publication`),
  ADD KEY `videos_auteur_id_index` (`auteur_id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `applications`
--
ALTER TABLE `applications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT pour la table `likes`
--
ALTER TABLE `likes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT pour la table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT pour la table `offers`
--
ALTER TABLE `offers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `password_reset_codes`
--
ALTER TABLE `password_reset_codes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT pour la table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT pour la table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=165;

--
-- AUTO_INCREMENT pour la table `projects`
--
ALTER TABLE `projects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `projets`
--
ALTER TABLE `projets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `quotes`
--
ALTER TABLE `quotes`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT pour la table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT pour la table `scholarships`
--
ALTER TABLE `scholarships`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT pour la table `types_competences`
--
ALTER TABLE `types_competences`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT pour la table `user_profiles`
--
ALTER TABLE `user_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pour la table `videos`
--
ALTER TABLE `videos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `applications`
--
ALTER TABLE `applications`
  ADD CONSTRAINT `applications_offer_id_foreign` FOREIGN KEY (`offer_id`) REFERENCES `offers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `applications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `likes`
--
ALTER TABLE `likes`
  ADD CONSTRAINT `likes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `likes_video_id_foreign` FOREIGN KEY (`video_id`) REFERENCES `videos` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `model_has_permissions`
--
ALTER TABLE `model_has_permissions`
  ADD CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `model_has_roles`
--
ALTER TABLE `model_has_roles`
  ADD CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `projects`
--
ALTER TABLE `projects`
  ADD CONSTRAINT `projects_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `projets`
--
ALTER TABLE `projets`
  ADD CONSTRAINT `projets_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `quotes`
--
ALTER TABLE `quotes`
  ADD CONSTRAINT `quotes_submitted_by_foreign` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `registration_audit_logs`
--
ALTER TABLE `registration_audit_logs`
  ADD CONSTRAINT `registration_audit_logs_process_id_foreign` FOREIGN KEY (`process_id`) REFERENCES `registration_processes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `registration_step_data`
--
ALTER TABLE `registration_step_data`
  ADD CONSTRAINT `registration_step_data_process_id_foreign` FOREIGN KEY (`process_id`) REFERENCES `registration_processes` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_admin_id_foreign` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `reports_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `role_has_permissions`
--
ALTER TABLE `role_has_permissions`
  ADD CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_registration_process_id_foreign` FOREIGN KEY (`registration_process_id`) REFERENCES `registration_processes` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `user_profiles`
--
ALTER TABLE `user_profiles`
  ADD CONSTRAINT `user_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `videos`
--
ALTER TABLE `videos`
  ADD CONSTRAINT `videos_auteur_id_foreign` FOREIGN KEY (`auteur_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
