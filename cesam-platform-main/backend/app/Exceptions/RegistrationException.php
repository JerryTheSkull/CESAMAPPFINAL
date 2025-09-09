<?php

// App/Exceptions/RegistrationException.php
namespace App\Exceptions;

use Exception;

class RegistrationException extends Exception
{
    protected $errors;

    public function __construct($message = "", $errors = null, $code = 0, Exception $previous = null)
    {
        parent::__construct($message, $code, $previous);
        $this->errors = $errors;
    }

    public function getErrors()
    {
        return $this->errors;
    }

    /**
     * Render the exception into an HTTP response.
     */
    public function render($request)
    {
        return response()->json([
            'success' => false,
            'message' => $this->getMessage(),
            'errors' => $this->getErrors()
        ], 400);
    }
}