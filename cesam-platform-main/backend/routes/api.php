<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\LogoutController;
use App\Http\Controllers\profil\UserProfileController;
use App\Http\Controllers\Api\Admin\UserManagementController;
use App\Http\Controllers\Api\AdminScholarshipController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\Admin\AdminReportController;
use App\Http\Controllers\Api\Admin\AdminVideoController;
use App\Http\Controllers\Api\VideoController;
use App\Http\Controllers\Api\Admin\VideoLikeController;
use App\Http\Controllers\Api\OfferController;
use App\Http\Controllers\Api\Admin\AdminOfferController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\Admin\QuoteController;
use App\Http\Controllers\Api\UserQuoteController;
use App\Http\Controllers\Api\NotificationController;

// ===================== ROUTES PUBLIQUES =====================

// Registration V2
Route::prefix('register/v2')->group(function () {
    Route::post('/step1', [RegisterController::class, 'step1'])->name('register.step1');
    Route::post('/step2', [RegisterController::class, 'step2'])->name('register.step2');
    Route::post('/step3', [RegisterController::class, 'step3'])->name('register.step3');
    Route::post('/step4', [RegisterController::class, 'step4'])->name('register.step4');
    Route::post('/step5', [RegisterController::class, 'step5'])->name('register.step5');
    Route::post('/resend-code', [RegisterController::class, 'resendVerificationCode'])->name('register.resend-code');
    Route::get('/step-data/{stepNumber}', [RegisterController::class, 'getStepData'])->where('stepNumber', '[1-5]')->name('register.step-data');
    Route::get('/status', [RegisterController::class, 'getProcessStatus'])->name('register.status');
    Route::post('/abandon', [RegisterController::class, 'abandonRegistration'])->name('register.abandon');
});

// Anciennes routes registration
Route::prefix('register')->group(function () {
    Route::post('/step1', [RegisterController::class, 'step1'])->name('register.legacy.step1');
    Route::post('/step2', [RegisterController::class, 'step2'])->name('register.legacy.step2');
    Route::post('/step3', [RegisterController::class, 'step3'])->name('register.legacy.step3');
    Route::post('/step4', [RegisterController::class, 'step4'])->name('register.legacy.step4');
    Route::post('/step5', [RegisterController::class, 'step5'])->name('register.legacy.step5');
    Route::post('/resend-code', [RegisterController::class, 'resendVerificationCode'])->name('register.legacy.resend-code');
});

// Login
Route::post('/login', [LoginController::class, 'login'])->name('login');

// Password Reset
Route::prefix('password-reset')->group(function () {
    Route::post('/send-code', [PasswordResetController::class, 'sendResetCode']);
    Route::post('/verify-code', [PasswordResetController::class, 'verifyResetCode']);
    Route::post('/reset', [PasswordResetController::class, 'resetPassword']);
});

// Public profile options
Route::get('/profile/options', [UserProfileController::class, 'getOptions'])->name('profile.options');

// Quote du jour
Route::get('/quote/latest', [UserQuoteController::class, 'latest']);

// Public videos
Route::prefix('videos')->group(function () {
    Route::get('/', [VideoController::class, 'index']);
    Route::get('/{id}', [VideoController::class, 'show']);
});

// Public reports accepted only
Route::prefix('reports')->group(function () {
    Route::get('/', [ReportController::class, 'index']);
    Route::get('/{id}', [ReportController::class, 'show']);
    Route::get('/{id}/download', [ReportController::class, 'downloadPdf']);
    Route::get('/{id}/view', [ReportController::class, 'viewPdf']);
    Route::get('/{id}/stream', [ReportController::class, 'streamPdf']);
});

// Public offers - CORRIGÉ
Route::prefix('offers')->group(function () {
    Route::get('/', [OfferController::class, 'index'])->name('offers.index');
    Route::get('/{offer}', [OfferController::class, 'show'])->name('offers.show');
});

// ===================== ROUTES PROTÉGÉES =====================
Route::middleware('auth:sanctum')->group(function () {

    // Logout
    Route::post('/logout', [LogoutController::class, 'logout'])->name('logout');

    // Notifications
    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index'])->name('notifications.index');
        Route::get('/unread', [NotificationController::class, 'unread'])->name('notifications.unread');
        Route::get('/unread-count', [NotificationController::class, 'unreadCount'])->name('notifications.unread-count');
        Route::patch('/{id}/read', [NotificationController::class, 'markAsRead'])->name('notifications.read');
        Route::patch('/mark-all-read', [NotificationController::class, 'markAllAsRead'])->name('notifications.mark-all-read');
        Route::delete('/{id}', [NotificationController::class, 'destroy'])->name('notifications.delete');
    });

    // Video likes
    Route::post('/videos/{id}/toggle-like', [VideoLikeController::class, 'toggleLike']);
    Route::get('/videos/{id}/like-status', [VideoLikeController::class, 'checkLikeStatus']);

    // Profile + projects
    Route::prefix('profile')->group(function () {
        Route::get('/', [UserProfileController::class, 'show'])->name('profile.show');
        Route::put('/', [UserProfileController::class, 'update'])->name('profile.update');
        Route::delete('/', [UserProfileController::class, 'destroy'])->name('profile.destroy');

        Route::put('/personal-info', [UserProfileController::class, 'updatePersonalInfo'])->name('profile.update-personal');
        Route::put('/academic-info', [UserProfileController::class, 'updateAcademicInfo'])->name('profile.update-academic');

        Route::post('/skills', [UserProfileController::class, 'addSkill'])->name('profile.add-skill');
        Route::put('/skills', [UserProfileController::class, 'updateAllSkills'])->name('profile.update-skills');
        Route::delete('/skills', [UserProfileController::class, 'removeSkill'])->name('profile.remove-skill');

        Route::get('/projects', [UserProfileController::class, 'getProjects'])->name('profile.get-projects');
        Route::post('/projects', [UserProfileController::class, 'addProject'])->name('profile.add-project');
        Route::get('/projects/{projectId}', [UserProfileController::class, 'getProject'])->name('profile.get-project');
        Route::put('/projects/{projectId}', [UserProfileController::class, 'updateProject'])->name('profile.update-project');
        Route::delete('/projects/{projectId}', [UserProfileController::class, 'deleteProject'])->name('profile.delete-project');

        Route::post('/cv', [UserProfileController::class, 'uploadCV'])->name('profile.upload-cv');
        Route::delete('/cv', [UserProfileController::class, 'deleteCV'])->name('profile.delete-cv');
        Route::get('/cv/download', [UserProfileController::class, 'downloadCV'])->name('profile.download-cv');

        Route::post('/photo', [UserProfileController::class, 'uploadProfilePhoto'])->name('profile.upload-photo');
        Route::delete('/photo', [UserProfileController::class, 'deleteProfilePhoto'])->name('profile.delete-photo');
    });

    // Reports submission
    Route::post('/reports', [ReportController::class, 'store']);

    // Offers apply - CORRIGÉ
    Route::prefix('offers')->group(function () {
        Route::post('/{offer}/apply', [OfferController::class, 'apply'])->name('offers.apply');
        Route::get('/my-applications', [OfferController::class, 'myApplications'])->name('offers.my-applications');
        Route::delete('/applications/{application}', [OfferController::class, 'cancelApplication'])->name('offers.cancel-application');
    });

    // Import Excel bourses (utilisateurs connectés)
    Route::get('/amci/scholarship/{matricule}', [AdminScholarshipController::class, 'getByMatricule']);

    // ===================== ADMIN =====================
    Route::middleware('admin')->prefix('admin')->group(function () {

        // Offers management - CORRIGÉ
        Route::prefix('offers')->group(function () {
            Route::get('/', [AdminOfferController::class, 'index'])->name('admin.offers.index');
            Route::post('/', [AdminOfferController::class, 'store'])->name('admin.offers.store');
            Route::get('/{offer}', [AdminOfferController::class, 'show'])->name('admin.offers.show');
            Route::delete('/{offer}', [AdminOfferController::class, 'destroy'])->name('admin.offers.destroy');
            Route::patch('/{offer}/toggle-status', [AdminOfferController::class, 'toggleStatus'])->name('admin.offers.toggle-status');
            Route::get('/{offer}/download-excel', [AdminOfferController::class, 'downloadExcel'])->name('admin.offers.download-excel');
            Route::get('/{offer}/applications', [AdminOfferController::class, 'applications'])->name('admin.offers.applications');
        });

        // Users management
        Route::get('/users', [UserManagementController::class, 'getUsers'])->name('admin.users.index');
        Route::get('/stats', [UserManagementController::class, 'getStats'])->name('admin.stats');
        Route::get('/users/available-roles', [UserManagementController::class, 'getAvailableRoles'])->name('admin.users.roles');
        Route::get('/users/{id}/details', [UserManagementController::class, 'getUserDetails'])->name('admin.users.show');
        Route::patch('/users/{id}/approval', [UserManagementController::class, 'approveUser'])->name('admin.users.approve');
        Route::patch('/users/{id}/role', [UserManagementController::class, 'changeRole'])->name('admin.users.change-role');
        Route::delete('/users/{id}', [UserManagementController::class, 'deleteUser'])->name('admin.users.delete');

        // Scholarships
        Route::prefix('scholarships')->group(function () {
            Route::get('/', [AdminScholarshipController::class, 'index'])->name('admin.scholarships.index');
            Route::get('/{id}', [AdminScholarshipController::class, 'show'])->name('admin.scholarships.show');
            Route::post('/', [AdminScholarshipController::class, 'store'])->name('admin.scholarships.store');
            Route::put('/{id}', [AdminScholarshipController::class, 'update'])->name('admin.scholarships.update');
            Route::delete('/{id}', [AdminScholarshipController::class, 'destroy'])->name('admin.scholarships.destroy');
            Route::post('/import', [AdminScholarshipController::class, 'import'])->name('admin.scholarships.import');
        });

        // Videos admin
        Route::prefix('videos')->group(function () {
            Route::get('/', [AdminVideoController::class, 'index'])->name('admin.videos.index');
            Route::post('/', [AdminVideoController::class, 'store'])->name('admin.videos.store');
            Route::get('/{id}', [AdminVideoController::class, 'show'])->name('admin.videos.show');
            Route::put('/{id}', [AdminVideoController::class, 'update'])->name('admin.videos.update');
            Route::delete('/{id}', [AdminVideoController::class, 'destroy'])->name('admin.videos.destroy');
            Route::patch('/{id}/toggle-status', [AdminVideoController::class, 'toggleStatus'])->name('admin.videos.toggle-status');
            Route::post('/{id}/duplicate', [AdminVideoController::class, 'duplicate'])->name('admin.videos.duplicate');
            Route::post('/{id}/schedule', [AdminVideoController::class, 'schedule'])->name('admin.videos.schedule');
            Route::post('/{id}/thumbnail', [AdminVideoController::class, 'uploadThumbnail'])->name('admin.videos.upload-thumbnail');
            Route::delete('/bulk', [AdminVideoController::class, 'bulkDelete'])->name('admin.videos.bulk-delete');
            Route::patch('/bulk-status', [AdminVideoController::class, 'bulkUpdateStatus'])->name('admin.videos.bulk-status');
            Route::get('/stats/dashboard', [AdminVideoController::class, 'getStats'])->name('admin.videos.stats');
            Route::get('/themes/management', [AdminVideoController::class, 'getThemesWithCount'])->name('admin.videos.themes');
        });

        // Reports admin
        Route::prefix('reports')->group(function () {
            Route::get('/', [AdminReportController::class, 'index'])->name('admin.reports.index');
            Route::get('/pending', [AdminReportController::class, 'pending'])->name('admin.reports.pending');
            Route::get('/{id}', [AdminReportController::class, 'show'])->name('admin.reports.show');
            Route::get('/{id}/history', [AdminReportController::class, 'history'])->name('admin.reports.history');
            Route::get('/{id}/download', [AdminReportController::class, 'downloadPdf'])->name('admin.reports.download');
            Route::get('/{id}/view', [AdminReportController::class, 'viewPdf'])->name('admin.reports.view');
            Route::get('/{id}/stream', [AdminReportController::class, 'streamPdf'])->name('admin.reports.stream');
            Route::put('/{id}', [AdminReportController::class, 'updateStatus'])->name('admin.reports.update');
            Route::patch('/{id}/accept', [AdminReportController::class, 'accept'])->name('admin.reports.accept');
            Route::patch('/{id}/reject', [AdminReportController::class, 'reject'])->name('admin.reports.reject');
            Route::patch('/{id}/cancel-acceptance', [AdminReportController::class, 'cancelAcceptance'])->name('admin.reports.cancel-acceptance');
            Route::patch('/{id}/cancel-rejection', [AdminReportController::class, 'cancelRejection'])->name('admin.reports.cancel-rejection');
        });

        // Quotes
        Route::prefix('quotes')->group(function () {
            Route::get('/', [QuoteController::class, 'index'])->name('admin.quotes.index');
            Route::post('/', [QuoteController::class, 'store'])->name('admin.quotes.store');
            Route::put('/{quote}', [QuoteController::class, 'update'])->name('admin.quotes.update');
            Route::delete('/{quote}', [QuoteController::class, 'destroy'])->name('admin.quotes.destroy');
            Route::patch('/{quote}/publish', [QuoteController::class, 'publish'])->name('admin.quotes.publish');
            Route::patch('/{quote}/unpublish', [QuoteController::class, 'unpublish'])->name('admin.quotes.unpublish');
        });

        // Admin import Excel bourses
        Route::post('/amci/import-excel', [AdminScholarshipController::class, 'import'])->name('admin.amci.import');
    });
});

// Fallback
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Route API non trouvée',
        'error' => 'Endpoint inexistant'
    ], 404);
})->name('api.fallback');